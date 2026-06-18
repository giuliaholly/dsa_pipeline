nextflow.enable.dsl=2

include { tumor_only as wf_tumor_only } from './workflows/tumor_only.nf'
//include { paired as wf_paired } from './workflows/paired.nf'

workflow {

    if( params.help ) {
        log.info '''
        -----------------------------------------------------------------------
        before the use, create a cache directory with:

	singularity pull docker://nanozoo/minimap2
	wget https://github.com/refresh-bio/KMC/releases/download/v3.2.4/KMC3.2.4.linux.arm64.tar.gz
	wget https://github.com/vgteam/vg/releases/latest
	wget https://github.com/dellytools/delly/releases/download/v2.1.0/delly-v2.1.0.sif
	wget https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-chm13.gbz
	vg index -t 10 -j hprc-v1.1-mc-chm13.dist --no-nested-distance hprc-v1.1-mc-chm13.gbz
	vg gbwt -p --num-threads 10 -r hprc-v1.1-mc-chm13.ri -Z hprc-v1.1-mc-chm13.gbz
	vg haplotypes -v 2 -t 10 -H hprc-v1.1-mc-chm13.hapl hprc-v1.1-mc-chm13.gbz
	cp /g/solexa/bin/software/kent/bin/x86_64/faSplit ${SINGULARITY_CACHE}
	cp /g/solexa/bin/software/kent/bin/x86_64/faCount ${SINGULARITY_CACHE}

	USE:

	WORK_DIR="/g/modbase/aml/"
	SINGULARITY_CACHE="/g/modbase/aml/cache"
	TS=$(date +%Y%m%d_%H%M%S)
	export TMPDIR="${WORK_DIR}/tmp"
	mkdir -p $TMPDIR
	export NXF_TEMP="${WORK_DIR}/tmp"
	export APPTAINER_TMPDIR="${WORK_DIR}/tmp"
	export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHE}"

	nextflow run main.nf --run pipeline --timestamp $TS --samplesheet samplesheet.csv --output_dir ./results -c nextflow.config -profile local --singularity_cache /g/modbase/aml/cache/ --bind_path ${WORK_DIR},${SINGULARITY_CACHE} -resume

        -----------------------------------------------------------------------
        '''.stripIndent()
        return
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
            row.normal?.trim()
        )
    }

if (params.run == 'pipeline') {

tumor_ch = samples_ch
    .filter { sample, tumor, normal -> tumor }
    .map    { sample, tumor, normal ->
        tuple(sample, file(tumor))
    }
    .ifEmpty {
        error """
        Workflow requires tumor fastq/bam input.
        Please provide 'tumor' column in samplesheet.
        """.stripIndent()
    }
wf_tumor_only(tumor_ch)
}

//if (params.run == 'paired') {

//tumor_ch = samples_ch
//    .filter { sample, tumor, normal -> tumor }
//    .map    { sample, tumor, normal ->
//        tuple(sample, file(tumor))
//    }
//    .ifEmpty {
//        error """
//        Workflow requires tumor fastq/bam input.
//        Please provide 'tumor' column in samplesheet.
//        """.stripIndent()
//    }
//normal_ch = samples_ch
//    .filter { sample, tumor, normal -> normal }
//    .map    { sample, tumor, normal ->
//        tuple(sample, file(normal))
//    }
//    .ifEmpty {
//        error """
//        Workflow requires normal fastq/bam input.
//        Please provide 'normal' column in samplesheet.
//        """.stripIndent()
//    }

//    wf_paired(tumor_ch, normal_ch)
//}

}
