nextflow.enable.dsl=2

process CLAIRS_TO {

    tag "${sample}.dsa${hap}"
    label 'big_job'

    input:
    tuple val(sample), val(hap), path(bam), path(bai), path(fasta), path(fai)

    output:
    tuple val(sample), val(hap), path("snv_${sample}.dsa.${hap}.vcf.gz"), path("snv_${sample}.dsa.${hap}.vcf.gz.tbi"), path("indel_${sample}.dsa.${hap}.vcf.gz"), path("indel_${sample}.dsa.${hap}.vcf.gz.tbi")

    script:

    """
    set -euo pipefail

    export TMPDIR=${params.tmp_dir}
    export TEMP=${params.tmp_dir}
    export TMP=${params.tmp_dir}

    export PARALLEL_HOME=${params.tmp_dir}
    export PARALLEL_TMPDIR=${params.tmp_dir}

    run_clairs_to -s ${sample}.dsa.${hap} -T ${bam} -R ${fasta} -t 32 -p ont_r10_dorado_sup_4khz --output_dir . --include_all_ctgs

    """
}
