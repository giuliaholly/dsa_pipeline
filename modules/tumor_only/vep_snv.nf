nextflow.enable.dsl=2

process VEP_SNV {

    tag "${sample}"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}/varbridge" }, mode: 'copy'

    input:
    tuple val(sample), path(somatic_snv_bcf), path(somatic_snv_bcf_tbi), path(dsa1_both_nolift_snv_bed), path(dsa2_both_nolift_snv_bed)

    output:
    tuple val(sample), path("${sample}.vep.snv.vcf")

    script:

    """
    /opt/vep/src/ensembl-vep/vep --cache --dir_cache ${params.vep_cache} --offline --fasta ${params.GRCh38} --input_file ${somatic_snv_bcf} --format bcf --output_file ${sample}.vep.snv.vcf --vcf --verbose --assembly GRCh38 --allele_number --pick_allele_gene --symbol --hgvs --canonical --mane --af_gnomadg --variant_class

    """
}
