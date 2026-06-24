nextflow.enable.dsl=2

process CHM13_SORT {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(sam)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.toCHM13.sorted.bam"), path("${sample}.dsa${hap}.toCHM13.sorted.bam.bai")


    script:

    """
    samtools sort -m 3G -o ${sample}.dsa${hap}.toCHM13.sorted.bam ${sam}
    samtools index ${sample}.dsa${hap}.toCHM13.sorted.bam

    """
}
