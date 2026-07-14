nextflow.enable.dsl=2

process SEVERUS_SV {

    tag "${sample}.dsa${hap}"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(bam), path(bai), path(trf)

    output:
    tuple val(sample), val(hap), path("all_SVs/${sample}.dsa${hap}.severus_all.vcf.gz"), path("all_SVs/${sample}.dsa${hap}.severus_all.vcf.gz.tbi")

    script:

    """
    severus --target-bam ${bam} --out-dir . -t 8  --vntr-bed ${trf}
    bgzip all_SVs/severus_all.vcf > all_SVs/${sample}.dsa${hap}.severus_all.vcf.gz
    tabix all_SVs/${sample}.dsa${hap}.severus_all.vcf.gz

    """
}
