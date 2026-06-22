nextflow.enable.dsl=2

process SAMTOOLS_SORT {

    tag "$sample"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(sam)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.sorted.bam"), path("${sample}.dsa${hap}.sorted.bam.bai")


    script:

    """
    samtools sort -m 3G -o ${sample}.dsa${hap}.sorted.bam ${sam}
    samtools index ${sample}.dsa${hap}.sorted.bam

    """
}
