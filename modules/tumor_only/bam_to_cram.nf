nextflow.enable.dsl=2

process BAM_TO_CRAM {

    tag "${sample}.dsa${hap}"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(fasta), path(sorted_bam), path(sorted_bai)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.cram")

    script:

    """

    samtools view -T ${fasta} -C -o ${sample}.dsa${hap}.cram ${sample}.dsa${hap}.sorted.bam

    """
}
