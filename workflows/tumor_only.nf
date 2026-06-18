nextflow.enable.dsl=2

include { BAMTOFQ } from '../modules/bamtofq.nf'
include { KMER_COUNT } from '../modules/kmer_count.nf'
include { VG_HAPLOTYPE } from '../modules/vg_haplotype.nf'
include { VG_PATH } from '../modules/vg_path.nf'
include { CREATE_DSA } from '../modules/create_dsa.nf'
include { ALIGN as ALIGN_HAP1 } from '../modules/align.nf'
include { ALIGN as ALIGN_HAP2 } from '../modules/align.nf'
include { SAMTOOLS_SORT as AMTOOLS_SORT1 } from '../modules/samtools_sort.nf'
include { SAMTOOLS_SORT as AMTOOLS_SORT2 } from '../modules/samtools_sort.nf'

workflow tumor_only {

    take:
    tumor_ch   // tuple(sample, tumor)

    main:
    fastq_ch = BAMTOFQ(tumor_ch)
    kmer_ch = KMER_COUNT(fastq_ch)
    vg_haplotype = VG_HAPLOTYPE(kmer_ch)
    vg_path = VG_PATH(vg_haplotype)
    dsa_ch = CREATE_DSA(vg_path)

    hap1_ch = dsa_ch.map { sample, fa1, fa2, cs1, cs2 ->
        tuple(sample, "1", fa1)
    }

    hap2_ch = dsa_ch.map { sample, fa1, fa2, cs1, cs2 ->
        tuple(sample, "2", fa2)
    }
    hap1_input = hap1_ch.combine(fastq_ch)
        .map { dsa, fq ->
            tuple(dsa[0], dsa[1], fq[1])
        }

    hap2_input = hap2_ch.combine(fastq_ch)
        .map { dsa, fq ->
            tuple(dsa[0], dsa[1], fq[1])
        }

    sam_hap1 = ALIGN_HAP1(align_hap1)
    sam_hap2 = ALIGN_HAP2(align_hap2)
    sorted_bam_hap1 = SAMTOOLS_SORT1(sam_hap1)
    sorted_bam_hap2 = SAMTOOLS_SORT2(sam_hap2)

    emit:
    bam1  = sorted_bam_hap1
    bam2  = sorted_bam_hap2
}
