nextflow.enable.dsl=2

include { BAMTOFQ } from '../modules/tumor_only/bamtofq.nf'
include { KMER_COUNT } from '../modules/tumor_only/kmer_count.nf'

workflow tumor_only {

    take:
    tumor_ch   // tuple(sample, tumor)

    main:
    fastq_ch = BAMTOFQ(tumor_ch)
    kmer_ch = KMER_COUNT(fastq_ch)

    emit:
    kmer     = kmer_ch
}
