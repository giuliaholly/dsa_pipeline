nextflow.enable.dsl=2

process FILTER_SV {

    tag "${sample}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}/varbridge" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(vep_sv_vcf)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.vep.sv.filtered.tsv")

    script:

    """
    PATTERN=\$(paste -sd'|' ${params.genes})

    (
        bcftools view -h ${vep_sv_vcf}
        bcftools view -H ${vep_sv_vcf} | \
        grep -P "CSQ=.*(\\\\b(\${PATTERN})\\\\b)"
    ) > ${sample}.dsa${hap}.vep.sv.filtered.vcf

    """
}
