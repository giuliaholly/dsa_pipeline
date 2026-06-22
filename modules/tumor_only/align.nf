nextflow.enable.dsl=2

process ALIGN {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(fasta), path(fastq)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.sam")


    script:

    """
    minimap2 -x map-ont -a -t 8 -y --secondary=no ${fasta} ${fastq} > ${sample}.dsa${hap}.sam

    """
}
