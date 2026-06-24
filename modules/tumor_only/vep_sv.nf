nextflow.enable.dsl=2

process VEP_SV {

    tag "${sample}"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}/varbridge" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(GRCh38_sv_vcf_gz), path(GRCh38_sv_vcf_gz_tbi), path(GRCh38_sv_nolift_bed)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.vep.sv.vcf")

    script:

    """
    /opt/vep/src/ensembl-vep/vep --cache --dir_cache ${params.vep_cache} --offline --fasta ${params.GRCh38} --input_file ${GRCh38_sv_vcf_gz} --output_file ${sample}.dsa${hap}.vep.sv.vcf --vcf --verbose --assembly GRCh38 --allele_number --pick_allele_gene --overlaps --buffer_size 10 --plugin CADD,${params.vep_cache}/CADD-SV/prescored_variants.tsv.gz --custom file=${params.vep_cache}/custom_files/gnomad.v4.1.sv.sites.vcf.gz,short_name=gnomad,fields=AF,format=vcf,type=overlap,overlap_cutoff=80,reciprocal=1,same_type=1 --custom ${params.vep_cache}/custom_files/benign_Ins_SV_GRCh38.sorted.bed.gz,Benign_Ins,bed,overlap,80 --custom ${params.vep_cache}/custom_files/benign_Gain_SV_GRCh38.sorted.bed.gz,Benign_Gain,bed,overlap,80 --custom ${params.vep_cache}/custom_files/benign_Loss_SV_GRCh38.sorted.bed.gz,Benign_Loss,bed,overlap,80 --custom ${params.vep_cache}/custom_files/benign_Ins_SV_GRCh38.sorted.bed.gz,Benign_Ins,bed,overlap,80 --custom ${params.vep_cache}/custom_files/benign_Inv_SV_GRCh38.sorted.bed.gz,Benign_Inv,bed,overlap,80

    """
}
