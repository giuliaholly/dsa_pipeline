nextflow.enable.dsl=2

process VARBRIDGE_SV {

    tag "${sample}.dsa${hap}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}/varbridge" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(consensus_bcf), path(consensus_bcf_csi), path(bam_to_GRCh38), path(bai_to_GRCh38)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}_to_GRCh38.sv.vcf.gz"), path("${sample}.dsa${hap}_to_GRCh38.sv.vcf.gz.tbi"), path("${sample}.dsa${hap}_to_GRCh38.sv.nolift.bed")

    script:

    """
    ${params.singularity_cache}/varbridge-v0.1.8-linux-amd64 lift -s ${sample}.dsa${hap}.sorted -o ${sample}.dsa${hap}_to_GRCh38.sv.vcf -b ${sample}.dsa${hap}_to_GRCh38.sv.nolift.bed -g ${params.GRCh38} -a ${consensus_bcf} ${bam_to_GRCh38}

    bcftools sort ${sample}.dsa${hap}_to_GRCh38.sv.vcf | bgzip > ${sample}.dsa${hap}_to_GRCh38.sv.vcf.gz
    tabix ${sample}.dsa${hap}_to_GRCh38.sv.vcf.gz
    rm ${sample}.dsa${hap}_to_GRCh38.sv.vcf

    """
}
