nextflow.enable.dsl=2

process INDEX {
    tag "${sample}.dsa${hap}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(fasta)

    output:
    tuple val(sample), val(hap), path("dsa.${sample}.${hap}.fa.fai")

    script:
    """
    samtools faidx ${fasta}
    """
}

