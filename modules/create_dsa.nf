nextflow.enable.dsl=2

process CREATE_DSA {

    tag "$sample"
    label 'medium_job'
    publishDir { "${params.output_dir}/${sample}" }, mode: 'copy'

    input:
    tuple val(sample), path(fasta)

    output:
    tuple val(sample), path("dsa.${sample}.1.fa"), path("dsa.${sample}.2.fa"), path("dsa.${sample}.1.chrom.sizes"), path("dsa.${sample}.2.chrom.sizes")

script:
    """
    set -euo pipefail

    mkdir -p splitFasta

    "${params.singularity_cache}/faSplit" byname "${fasta}" splitFasta/

    for H in 1 2
    do
        FILES=\$(ls splitFasta/recombination#\${H}#chr*.fa 2>/dev/null | sort -V || true)

        if [ -n "\$FILES" ]
        then
            cat \$FILES \\
            | sed -E 's/^>recombination#[12]#(.*)\$/>\\1/' \\
            > dsa.${sample}.\$H.fa

            rm -f \$FILES
	    ${params.singularity_cache}/faCount dsa.${sample}.\$H.fa > dsa.${sample}.\$H.chrom.sizes
        fi
    done
    """

}
