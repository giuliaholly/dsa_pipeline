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
    bcftools +split-vep ${vep_snv_vcf} -f '%CHROM\t%POS\t%REF\t%ALT\t%SYMBOL\t%Consequence\t%CADD_PHRED\n' > ${sample}.vep.snv.tsv

    awk '
    NR==FNR { genes[\$1]=1; next }
    \$5 != "" && \$5 in genes
    ' ${params.genes} ${sample}.vep.snv.tsv \
    > ${sample}.vep.snv.filtered.tsv

    """
}
