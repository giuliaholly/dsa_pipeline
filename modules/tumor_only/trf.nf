nextflow.enable.dsl=2

process TRF {

    tag "${sample}.dsa${hap}"
    label 'big_job'

    input:
    tuple val(sample), val(hap), path(fasta)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.trf.bed")

    script:

    """
    export PATH="${params.work_dir}/mamba/bin:\${PATH}"
    python3 ${params.singularity_cache}/findTandemRepeats --merge ${fasta} ${sample}.dsa${hap}.trf.bed

    """
}
