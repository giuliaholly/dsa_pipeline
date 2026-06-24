nextflow.enable.dsl=2

process DELLY_SV {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(bam), path(bai), path(fasta)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.delly.bcf")
    script:

    """
    delly lr -g ${fasta} -o ${sample}.dsa${hap}.delly.bcf ${bam}

    """
}
