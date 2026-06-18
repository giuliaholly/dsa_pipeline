nextflow.enable.dsl=2

process VG_HAPLOTYPE {

    tag "$sample"
    label 'big_job'

    input:
    tuple val(sample), path("${sample}.kff")

    output:
    tuple val(sample), path("${sample}.gbz"), path("${sample}.haplotype")

    script:

    """
    ${params.singularity_cache}/vg haplotypes -v 2 -t 8 --include-reference --diploid-sampling -i ${params.singularity_cache}/hprc-v2.0-mc-chm13.hapl -k ${sample}.kff -g ${sample}.gbz --haplotype-output ${sample}.haplotype ${params.singularity_cache}/hprc-v2.0-mc-chm13.gbz

    """
}
