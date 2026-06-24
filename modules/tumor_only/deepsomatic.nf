nextflow.enable.dsl=2

process DEEPSOMATIC {

    tag "${sample}.dsa${hap}"
    label 'big_job'

    input:
    tuple val(sample), val(hap), path(bam), path(bai), path(fasta), path(fai)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.deepsomatic.bcf")

    script:

    """
    rm -rf ${sample}.dsa${hap}.deepsomatic 
    set -euo pipefail

    export TMPDIR=${params.tmp_dir}
    export TEMP=${params.tmp_dir}
    export TMP=${params.tmp_dir}

    export PARALLEL_HOME=${params.tmp_dir}
    export PARALLEL_TMPDIR=${params.tmp_dir}

    run_deepsomatic --model_type=ONT_TUMOR_ONLY --ref=${fasta} --reads_tumor=${bam} --output_vcf=${sample}.dsa${hap}.deepsomatic.bcf --sample_name_tumor="${sample}.dsa${hap}" --num_shards=16 --logging_dir=${sample}.dsa${hap}.deepsomatic/output/logs --intermediate_results_dir=${sample}.dsa${hap}.deepsomatic/output/intermediate_results_dir

    """
}
