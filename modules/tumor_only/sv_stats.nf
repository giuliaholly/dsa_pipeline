nextflow.enable.dsl=2

process SV_STATS {

    tag "${sample}.dsa${hap}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(bcf), path(csi)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.sv.stats")

    script:

    """
        echo "Sample: ${sample}.dsa${hap}" > ${sample}.dsa${hap}.sv.stats

        bcftools view ${bcf} \
            | grep -v "^#" \
            | cut -f3 \
            | cut -c1-3 \
            | sort \
            | uniq -c \
            >> ${sample}.dsa${hap}.sv.stats

        echo -n "TOTAL " >> ${sample}.dsa${hap}.sv.stats

        bcftools view ${bcf} \
            | grep -v "^#" \
            | wc -l \
        >> ${sample}.dsa${hap}.sv.stats

    """
}
