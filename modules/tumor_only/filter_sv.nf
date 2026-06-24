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
    bcftools +split-vep ${vep_sv_vcf} -f '%CHROM\t%POS\t%REF\t%ALT\t%SYMBOL\t%Consequence\t%CADD_PHRED\n' > ${sample}.dsa${hap}.vep.sv.tsv

    awk '
    NR==FNR { genes[\$1]=1; next }
    \$5 != "" && \$5 in genes
    ' ${params.genes} ${sample}.dsa${hap}.vep.sv.tsv \
    > ${sample}.dsa${hap}.vep.sv.filtered.tsv

    """
}
