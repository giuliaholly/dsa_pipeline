nextflow.enable.dsl=2

include { tumor_only as wf_tumor_only } from './workflows/tumor_only.nf'
include { tumor_normal as wf_tumor_normal } from './workflows/tumor_normal.nf'

workflow {

    if( params.help ) {
        log.info '''
        -----------------------------------------------------------------------
        # DSA Pipeline

	        Personalized reference construction and somatic variant discovery from ONT tumor sequencing data.

	        ## DESCRIPTION

	        DSA Pipeline builds a donor-specific diploid assembly (DSA) from the Human Pangenome,
	        aligns Oxford Nanopore (ONT) reads against the personalized reference, performs SNV
	        and SV calling, lifts variants to GRCh38 coordinates using VarBridge, annotates
	        variants with Ensembl VEP, and optionally prioritizes variants in user-defined genes.
	        If tumor_only mode, the DSA will be constructed based on tumor ONT reads. 
	        If tumor_normal mode, the DSA will be constructed based on normal short-reads fastq,
	        then tumor ONT reads will be aligned to the DSA and used for variant calling.

	        Current release supports both tumor-only and tumor-normal analysis.

	        ## FEATURES

	        * Personalized diploid reference construction from the Human Pangenome
	        * ONT BAM and FASTQ input support
	        * Multi-sample processing
	        * SNV calling
	        * SV calling
	        * Liftover to GRCh38 using VarBridge
	        * Somatic variant filtering
	        * Ensembl VEP annotation
	        * Gene panel prioritization

	        ## INPUT

	        Samples must be provided through a tab-separated CSV file with header:

	        sample,tumor,normal_R1,normal_R2

	        Example:

	        sample,tumor,normal_R1,normal_R2
	        PAT001,/data/tumor.bam,/data/normal_R1.fastq,/data/normal_R2.fastq
	        PAT002,/data/tumor.fastq,/data/normal_R1.fastq,/data/normal_R2.fastq
	        PAT002,/data/tumor.fastq,,

	        For tumor-only mode, leave the normal column empty.

	        ## REQUIRED PARAMETERS

	        --run                  Workflow mode (tumor_only or tumor_normal)
	        --samplesheet          Parth to sample sheet
	        --output_dir           Output directory
	        --work_dir             Working directory
	        --GRCh38               GRCh38 reference FASTA
	        --CHM13                CHM13 reference FASTA
	        --vep_cache            Ensembl VEP cache directory
	        --singularity_cache    Apptainer/Singularity cache directory
	        --bind_path            Comma-separated list of bind-mounted directories
	        --tmp_dir              Temporary directory
	        --timestamp            Run timestamp

	        ## OPTIONAL PARAMETERS

	        --genes                Gene list for variant prioritization


	        ## EXECUTION

	        SLURM (recommended):

	        nextflow run dsa_pipeline/main.nf 
	        --run tumor_only 
	        --samplesheet samplesheet.csv 
	        --output_dir results 
	        --work_dir /path/to/workdir 
	        --GRCh38 GRCh38.fa 
	        --CHM13 CHM13.fa 
	        --vep_cache /path/to/vep_cache 
	        --singularity_cache /path/to/cache 
	        --bind_path /path1,/path2 
	        -profile slurm

	        ## OUTPUTS

	        Results are written to:

	        output_dir/SAMPLE_NAME/

	        Key results are located in:

	        output_dir/SAMPLE_NAME/varbridge/

	        Contents include:

	        * Variants lifted to GRCh38
	        * Somatic-filtered variants
	        * VEP-annotated variants
	        * Gene-prioritized variants (when --genes is supplied)

	        ## GENE PRIORITIZATION

	        Provide a text file containing one gene symbol per line:
	
	        TP53
	        FLT3
	        NPM1
	        RUNX1
	        DNMT3A
        
	        Use:

	        --genes genes.txt

	        ## STATUS

	        Supported:

	        * Tumor-only and tumor-normal mode
	        * ONT BAM or FASTQ input for tumor sample
	        * Short reads paired-end FASTQ input for normal sample
	        * Multi-sample processing
	        * SNV calling
	        * SV calling
	        * VEP annotation
	        * Gene panel prioritization

	        In development:

	        * Somatic paired calling
	        * Karyotype analysis/CNV calling

	        ## REFERENCES

	        Human Pangenome: https://humanpangenome.org
	        VarBridge: https://github.com/tobiasrausch/VarBridge
	        Ensembl VEP: https://www.ensembl.org/info/docs/tools/vep


        -----------------------------------------------------------------------
        '''.stripIndent()
        return
    }

def required_params = [
    'run',
    'samplesheet',
    'output_dir',
    'work_dir',
    'GRCh38',
    'CHM13',
    'vep_cache',
    'singularity_cache'
]

def missing = required_params.findAll { !params[it] }

if( missing ) {
    log.error """
    ERROR: Missing required parameter(s):

    ${missing.collect { "--${it}" }.join('\n    ')}

    Example:

    nextflow run main.nf \
        --run pipeline \
        --samplesheet samplesheet.csv \
        --output_dir results \
        --work_dir /path/to/workdir \
        --GRCh38 GRCh38.fa \
        --CHM13 CHM13.fa \
        --vep_cache /path/to/vep_cache \
        --singularity_cache /path/to/cache \
        --bind_path /path1,/path2
    """
    System.exit(1)
}

samples_ch = Channel
    .fromPath(params.samplesheet)
    .splitCsv(header: true)
    .map { row ->

        def sample = row.sample
        if (!sample)
            error "Missing sample name in samplesheet row: ${row}"

        tuple(
            sample,
            row.tumor?.trim(),
            row.normal_R1?.trim(),
            row.normal_R2?.trim()
        )
    }

tumor_ch = samples_ch
    .filter { sample, tumor, normal_R1, normal_R2 -> tumor }
    .map    { sample, tumor, normal_R1, normal_R2 ->
        tuple(sample, file(tumor))
    }

normal_ch = samples_ch
    .filter { sample, tumor, normal_R1, normal_R2 ->
        normal_R1 && normal_R2
    }
    .map { sample, tumor, normal_R1, normal_R2 ->
        tuple(
            sample,
            [
                file(normal_R1),
                file(normal_R2)
            ]
        )
    }

if (params.run == 'tumor_only') {

    tumor_ch = tumor_ch.ifEmpty {
        error """
        Workflow requires tumor fastq/bam input.
        Please provide 'tumor' column in samplesheet.
        """.stripIndent()
    }

    wf_tumor_only(tumor_ch)

}
else if (params.run == 'tumor_normal') {

    tumor_ch = tumor_ch.ifEmpty {
        error "Tumor input missing."
    }

    normal_ch = normal_ch.ifEmpty {
        error "Normal input missing."
    }

    wf_tumor_normal(tumor_ch, normal_ch)

}
else {

    error """
    Invalid value for --run: '${params.run}'

    Allowed values are:
      - tumor_only
      - tumor_normal
    """.stripIndent()

}
}
