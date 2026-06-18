nextflow.enable.dsl=2

process VG_PATH {

    tag "$sample"
    label 'medium_job'

    input:
    tuple val(sample), path(gbz), path(haplotype)

    output:
    tuple val(sample), path("${sample}.fa")

    script:

    """
    ${params.singularity_cache}/vg paths -x ${sample}.gbz -F -S 'recombination' > ${sample}.fa

    """
}
