nextflow.enable.dsl=2

process BAMTOFQ {
    tag "$sample"
    label 'big_job'

    input:
    tuple val(sample), path(tumor_ch)

    output:
    tuple val(sample), path("${sample}.fastq")

    script:
    def ext = tumor_ch.getName().tokenize('.')[-1]

    if (ext == 'bam') {
        """
        samtools fastq -T Mm,Ml ${tumor_ch} > ${sample}.fastq
        """
    } else if (ext == 'fastq') {
        """
        cp ${tumor_ch} ${sample}.fastq
        """
    } else {
        error "Unsupported file extension: $ext"
    }
}

