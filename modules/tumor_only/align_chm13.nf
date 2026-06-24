nextflow.enable.dsl=2

process ALIGN_CHM13 {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(fasta)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.toCHM13.sam")


    script:

    """
    minimap2 -a -x asm5 --cs ${params.CHM13} ${fasta} > ${sample}.dsa${hap}.toCHM13.sam

    """
}
