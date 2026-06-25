nextflow.enable.dsl=2

process FILTER_SNV {

    tag "${sample}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}/varbridge" }, mode: 'copy'

    input:
    tuple val(sample), path(vep_snv_vcf)

    output:
    tuple val(sample), path("${sample}.vep.snv.filtered.tsv")

    script:

    """
    PATTERN=\$(paste -sd'|' ${params.genes})

    (
        bcftools view -h ${vep_snv_vcf}
        bcftools view -H ${vep_snv_vcf} | \
        grep -P "CSQ=.*(\\\\b(\${PATTERN})\\\\b)"
    ) > ${sample}.dsa${hap}.vep.snv.filtered.vcf

    """
}
