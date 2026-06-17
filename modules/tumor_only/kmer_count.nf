nextflow.enable.dsl=2

process KMER_COUNT {

    tag "$sample"
    label 'big_job'

    input:
    tuple val(sample), path(fastq_ch)

    output:
    tuple val(sample), path("${sample}.kff")

    script:

    def cache = System.getenv('SINGULARITY_CACHE')

    """
    ${params.singularity_cache}/kmc_3.2.4/bin/kmc -k29 -m128 -okff ${fastq_ch} ${sample} .

    """
}
