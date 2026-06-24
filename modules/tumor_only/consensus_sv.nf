nextflow.enable.dsl=2

process CONSENSUS_SV {

    tag "${sample}.dsa${hap}"
    label 'small_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(delly), path(delly_index), path(severus), path(severus_tbi)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.consensus.somatic.SV.bcf"), path("${sample}.dsa${hap}.consensus.somatic.SV.bcf.csi")

    script:

    """
    sansa compvcf \
        --nosvt \
        -a ${severus} \
        -e 0 \
        -m 0 \
        -n 250000000 \
        ${delly}

    awk '\$2=="TP"' out.sv.classification \
        | cut -f1 \
        | sort -u \
        > delly.tp

    bcftools query -f '%ID\n' ${delly} \
        | sort -u \
        > all.sv

    grep -v -w -Ff delly.tp all.sv > remove.sv

    bcftools view ${delly} \
        | grep -v -w -Ff remove.sv \
        | bcftools view -Ob \
        -o ${sample}.dsa${hap}.consensus.somatic.SV.bcf

    bcftools index -f ${sample}.dsa${hap}.consensus.somatic.SV.bcf

    """
}
