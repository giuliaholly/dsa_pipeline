nextflow.enable.dsl=2

process VARBRIDGE_SNV {

    tag "${sample}.dsa${hap}"
    label 'small_job'

    input:
    tuple val(sample), val(hap), path(consensus_bcf), path(consensus_bcf_csi), path(bam_to_GRCh38), path(bai_to_GRCh38), path(bam_to_CHM13), path(bai_to_CHM13)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}_to_GRCh38.snv.vcf.gz"), path("${sample}.dsa${hap}_to_GRCh38.snv.vcf.gz.tbi"), path("${sample}.dsa${hap}_to_GRCh38.snv.nolift.bed"), path("${sample}.dsa${hap}_to_CHM13.snv.vcf.gz"), path("${sample}.dsa${hap}_to_CHM13.snv.vcf.gz.tbi"), path("${sample}.dsa${hap}_to_CHM13.snv.nolift.bed")

    script:

    """
    ${params.singularity_cache}/varbridge-v0.1.8-linux-amd64 lift -s ${sample}.dsa.${hap} -o ${sample}.dsa${hap}_to_GRCh38.snv.vcf -b ${sample}.dsa${hap}_to_GRCh38.snv.nolift.bed -g ${params.GRCh38} -a ${consensus_bcf} ${bam_to_GRCh38}

    bcftools sort ${sample}.dsa${hap}_to_GRCh38.snv.vcf | bgzip > ${sample}.dsa${hap}_to_GRCh38.snv.vcf.gz
    tabix ${sample}.dsa${hap}_to_GRCh38.snv.vcf.gz
    rm ${sample}.dsa${hap}_to_GRCh38.snv.vcf
    
    ${params.singularity_cache}/varbridge-v0.1.8-linux-amd64 lift -s ${sample}.dsa.${hap} -o ${sample}.dsa${hap}_to_CHM13.snv.vcf -b ${sample}.dsa${hap}_to_CHM13.snv.nolift.bed -g ${params.CHM13} -a ${consensus_bcf} ${bam_to_CHM13}

    bcftools sort ${sample}.dsa${hap}_to_CHM13.snv.vcf | bgzip > ${sample}.dsa${hap}_to_CHM13.snv.vcf.gz
    tabix ${sample}.dsa${hap}_to_CHM13.snv.vcf.gz
    rm ${sample}.dsa${hap}_to_CHM13.snv.vcf

    """
}
