nextflow.enable.dsl=2

process DELLY_INDEX {

    tag "${sample}.dsa${hap}"
    label 'medium_job'

    input:
    tuple val(sample), val(hap), path(sv_bcf), path(cov_gz), path(cnv_bcf), path(seg_bed)


    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.delly.bcf.csi"), path("${sample}.dsa${hap}.delly.cnv.bcf.csi")

    script:

    """
    bcftools index ${sv_bcf}
    bcftools index ${cnv_bcf}

    """
}
