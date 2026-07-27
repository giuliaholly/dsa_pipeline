nextflow.enable.dsl=2

process CONSENSUS_SNV {

    tag "${sample}.dsa${hap}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(clair_snv), path(clair_snv_tbi), path(clair_indel), path(clair_indel_tbi)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.tumor.filtered.clair3.bcf"), path("${sample}.dsa${hap}.tumor.filtered.clair3.bcf.csi")

    script:

    """
    bcftools concat -a -O b -o ${sample}.dsa${hap}.tumor.raw.clair3.bcf ${clair_snv} ${clair_indel}
    bcftools index ${sample}.dsa${hap}.tumor.raw.clair3.bcf

    bcftools view -f 'PASS,.' -v snps,indels -m 2 -M 2 -i 'sum(AD) > 5' -O b -o ${sample}.dsa${hap}.tumor.filtered.clair3.bcf ${sample}.dsa${hap}.tumor.raw.clair3.bcf
    bcftools index ${sample}.dsa${hap}.tumor.filtered.clair3.bcf
    rm ${sample}.dsa${hap}.tumor.raw.clair3.bcf ${sample}.dsa${hap}.tumor.raw.clair3.bcf.csi

    """
}
