nextflow.enable.dsl=2

process CONSENSUS_SNV {

    tag "${sample}.dsa${hap}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(clair_snv), path(clair_snv_tbi), path(clair_indel), path(clair_indel_tbi), path(deepsomatic)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.consensus.somatic.SNV.bcf"), path("${sample}.dsa${hap}.consensus.somatic.SNV.bcf.csi")

    script:

    """
    bcftools concat -a -O b -o ${sample}.dsa${hap}.tumor.raw.clair3.bcf ${clair_snv} ${clair_indel}
    bcftools index ${sample}.dsa${hap}.tumor.raw.clair3.bcf

    bcftools view -f 'PASS,.' -v snps,indels -m 2 -M 2 -i 'sum(AD) > 5' -O b -o ${sample}.dsa${hap}.tumor.filtered.clair3.bcf ${sample}.dsa${hap}.tumor.raw.clair3.bcf
    bcftools index ${sample}.dsa${hap}.tumor.filtered.clair3.bcf
    rm ${sample}.dsa${hap}.tumor.raw.clair3.bcf ${sample}.dsa${hap}.tumor.raw.clair3.bcf.csi

    bcftools view -f 'PASS,.' -v snps,indels -m 2 -M 2 -i 'sum(AD) > 5' -O b -o ${sample}.dsa${hap}.tumor.filtered.ds.bcf ${deepsomatic}
    bcftools index ${sample}.dsa${hap}.tumor.filtered.ds.bcf

    bcftools isec -O b -o ${sample}.dsa${hap}.consensus.somatic.SNV.bcf -n=2 -w1 ${sample}.dsa${hap}.tumor.filtered.clair3.bcf ${sample}.dsa${hap}.tumor.filtered.ds.bcf
    bcftools index ${sample}.dsa${hap}.consensus.somatic.SNV.bcf
    rm ${sample}.dsa${hap}.tumor.filtered.ds.bcf ${sample}.dsa${hap}.tumor.filtered.ds.bcf.csi
    rm ${sample}.dsa${hap}.tumor.filtered.clair3.bcf ${sample}.dsa${hap}.tumor.filtered.clair3.bcf.csi

    """
}
