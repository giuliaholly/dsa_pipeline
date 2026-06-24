nextflow.enable.dsl=2

process GRCh38_SORT {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(sam)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.toGRCh38.sorted.bam"), path("${sample}.dsa${hap}.toGRCh38.sorted.bam.bai")


    script:

    """
    samtools sort -m 3G -o ${sample}.dsa${hap}.toGRCh38.sorted.bam ${sam}
    samtools index ${sample}.dsa${hap}.toGRCh38.sorted.bam

    """
}
