nextflow.enable.dsl=2

include { BAMTOFQ } from '../modules/bamtofq.nf'
include { KMER_COUNT } from '../modules/kmer_count.nf'
include { VG_HAPLOTYPE } from '../modules/vg_haplotype.nf'
include { VG_PATH } from '../modules/vg_path.nf'
include { CREATE_DSA } from '../modules/create_dsa.nf'
include { ALIGN } from '../modules/tumor_only/align.nf'
include { SAMTOOLS_SORT } from '../modules/tumor_only/samtools_sort.nf'

workflow tumor_only {

    take:
    tumor_ch   // tuple(sample, tumor)

    main:
    fastq_ch = BAMTOFQ(tumor_ch)
    fastq_for_kmer  = fastq_ch
    fastq_for_align = fastq_ch
    kmer_ch = KMER_COUNT(fastq_for_kmer)
    vg_haplotype = VG_HAPLOTYPE(kmer_ch)
    vg_path = VG_PATH(vg_haplotype)
    dsa_ch = CREATE_DSA(vg_path)
    haplotype_ch = dsa_ch.flatMap { sample, dsa1, dsa2, chr1, chr2 ->

        [
            tuple(sample, 1, dsa1),
            tuple(sample, 2, dsa2)
        ]
    }
    align_input = haplotype_ch.combine(fastq_for_align, by: 0)
    sam_ch = ALIGN(align_input)
    sorted_bam = SAMTOOLS_SORT (sam_ch)
    

    emit:
    dsa  = dsa_ch
}
