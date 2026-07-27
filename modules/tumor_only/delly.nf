nextflow.enable.dsl=2

process DELLY_SV {

    tag "${sample}.dsa${hap}"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), val(hap), path(bam), path(bai), path(fasta)

    output:
    tuple val(sample), val(hap), path("${sample}.dsa${hap}.delly.bcf"), path("${sample}.dsa${hap}.delly.cov.gz"), path("${sample}.dsa${hap}.delly.cnv.bcf"), path("${sample}.dsa${hap}.delly.seg.bed")

    script:

    """
    delly lr -g ${fasta} -o ${sample}.dsa${hap}.delly.bcf ${bam}
    delly cnv -g ${fasta} -c ${sample}.dsa${hap}.delly.cov.gz -o ${sample}.dsa${hap}.delly.cnv.bcf -u ${sample}.dsa${hap}.delly.seg.bed ${bam}

    """
}
