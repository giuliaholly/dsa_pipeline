nextflow.enable.dsl=2

process ALIGN_GRCh38 {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(fasta)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.toGRCh38.sam")


    script:

    """
    minimap2 -a -x asm5 --cs ${params.GRCh38} ${fasta} > ${sample}.dsa${hap}.toGRCh38.sam

    """
}
