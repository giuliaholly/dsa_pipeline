nextflow.enable.dsl=2

process FILTER_VARBRIDGE_SNV {

    tag "${sample}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}/varbridge" }, mode: 'copy'

    input:
    tuple val(sample), val(hap1), path(hap1_GRCh38_vcf), path(hap1_GRCh38_tbi), path(hap1_GRCh38_bed), path(hap1_CHM13_vcf), path(hap1_CHM13_tbi), path(hap1_CHM13_bed), val(hap2), path(hap2_GRCh38_vcf), path(hap2_GRCh38_tbi), path(hap2_GRCh38_bed), path(hap2_CHM13_vcf), path(hap2_CHM13_tbi), path(hap2_CHM13_bed)

    output:
    tuple val(sample), path("${sample}.GRCh38.somatic.snv.bcf"), path("${sample}.GRCh38.somatic.snv.bcf.csi"), path("${sample}.dsa1.both.nolift.snv.bed"), path("${sample}.dsa2.both.nolift.snv.bed")

    script:

    """
    
    bcftools isec -O b -o ${sample}.GRCh38.bcf -n=2 -w1 ${hap1_GRCh38_vcf} ${hap2_GRCh38_vcf}
    bcftools index ${sample}.GRCh38.bcf

    bcftools isec -O b -o ${sample}.CHM13.bcf -n=2 -w1 ${hap1_CHM13_vcf} ${hap2_CHM13_vcf}
    bcftools index ${sample}.CHM13.bcf

    bcftools query -f "%LIFT_SRC\t%REF_ALT_SWAP\n" ${sample}.GRCh38.bcf | awk '\$2==1 {print \$1}' > remove.IDs
    bcftools query -f "%LIFT_SRC\t%REF_ALT_SWAP\n" ${sample}.CHM13.bcf | awk '\$2==1 {print \$1}' >> remove.IDs

    bcftools query -f "%LIFT_SRC\n" ${sample}.GRCh38.bcf > ids.part1.tsv
    bcftools query -f "%LIFT_SRC\n" ${sample}.CHM13.bcf > ids.part2.tsv

    sort ids.part*.tsv | sort | uniq -u >> remove.IDs
    rm ids.part1.tsv ids.part2.tsv

    sort remove.IDs | uniq > remove.IDs.tmp
    mv remove.IDs.tmp remove.IDs

    bcftools view ${sample}.GRCh38.bcf | grep -v -w -Ff remove.IDs | bcftools view -O b -o ${sample}.GRCh38.somatic.snv.bcf -
    bcftools index ${sample}.GRCh38.somatic.snv.bcf

    rm remove.IDs

    sort <(cut -f 4 ${hap1_GRCh38_bed} | sort -u) \
         <(cut -f 4 ${hap1_CHM13_bed} | sort -u) \
    | uniq -d > ${sample}.dsa1.both.nolift.ids

    awk 'NR==FNR {a[\$1]=1; next} \$4 in a' \
        ${sample}.dsa1.both.nolift.ids \
        ${hap1_GRCh38_bed} \
        > ${sample}.dsa1.both.nolift.snv.bed

    rm ${sample}.dsa1.both.nolift.ids


    sort <(cut -f 4 ${hap2_GRCh38_bed} | sort -u) \
         <(cut -f 4 ${hap2_CHM13_bed} | sort -u) \
    | uniq -d > ${sample}.dsa2.both.nolift.ids

    awk 'NR==FNR {a[\$1]=1; next} \$4 in a' \
        ${sample}.dsa2.both.nolift.ids \
        ${hap2_GRCh38_bed} \
        > ${sample}.dsa2.both.nolift.snv.bed

    rm ${sample}.dsa2.both.nolift.ids

    """
}
