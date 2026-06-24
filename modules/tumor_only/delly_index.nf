nextflow.enable.dsl=2

process DELLY_INDEX {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(bcf)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.delly.bcf.csi")

    script:

    """
    bcftools index ${bcf}
    """
}
