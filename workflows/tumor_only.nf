nextflow.enable.dsl=2

include { BAMTOFQ } from '../modules/bamtofq.nf'
include { KMER_COUNT } from '../modules/kmer_count.nf'
include { VG_HAPLOTYPE } from '../modules/vg_haplotype.nf'
include { VG_PATH } from '../modules/vg_path.nf'
include { CREATE_DSA } from '../modules/create_dsa.nf'
include { INDEX } from '../modules/index.nf'
include { ALIGN } from '../modules/tumor_only/align.nf'
include { ALIGN_GRCh38 } from '../modules/tumor_only/align_grch38.nf'
include { ALIGN_CHM13 } from '../modules/tumor_only/align_chm13.nf'
include { SAMTOOLS_SORT } from '../modules/tumor_only/samtools_sort.nf'
include { GRCh38_SORT } from '../modules/tumor_only/GRCh38_sort.nf'
include { CHM13_SORT } from '../modules/tumor_only/CHM13_sort.nf'
include { DELLY_SV } from '../modules/tumor_only/delly.nf'
include { DELLY_INDEX } from '../modules/tumor_only/delly_index.nf'
include { TRF } from '../modules/tumor_only/trf.nf'
include { SEVERUS_SV } from '../modules/tumor_only/severus.nf'
include { CLAIRS_TO } from '../modules/tumor_only/clairs_to.nf'
include { DEEPSOMATIC } from '../modules/tumor_only/deepsomatic.nf'
include { CONSENSUS_SV } from '../modules/tumor_only/consensus_sv.nf'
include { SV_STATS } from '../modules/tumor_only/sv_stats.nf'
include { CONSENSUS_SNV } from '../modules/tumor_only/consensus_snv.nf'
include { VARBRIDGE_SNV } from '../modules/tumor_only/varbridge_snv.nf'
include { VARBRIDGE_SV } from '../modules/tumor_only/varbridge_sv.nf'
include { FILTER_VARBRIDGE_SNV } from '../modules/tumor_only/filter_varbridge_snv.nf'
include { VEP_SNV } from '../modules/tumor_only/vep_snv.nf'
include { VEP_SV } from '../modules/tumor_only/vep_sv.nf'
include { FILTER_SNV } from '../modules/tumor_only/filter_snv.nf'
include { FILTER_SV } from '../modules/tumor_only/filter_sv.nf'


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
    fa_index = INDEX(haplotype_ch)
    align_input = haplotype_ch.combine(fastq_for_align, by: 0)
    sam_ch = ALIGN(align_input)
    dsa_to_GRCh38 = ALIGN_GRCh38(haplotype_ch)
    dsa_to_CHM13 = ALIGN_CHM13(haplotype_ch)
    sorted_bam = SAMTOOLS_SORT(sam_ch)
    sorted_grch38 = GRCh38_SORT(dsa_to_GRCh38)
    sorted_chm13 = CHM13_SORT(dsa_to_CHM13)
    delly_input = sorted_bam.join(haplotype_ch, by: [0,1])
    clair_input = sorted_bam.join(haplotype_ch, by: [0,1]).join(fa_index, by:[0,1])
    deepsomatic_input = sorted_bam.join(haplotype_ch, by: [0,1]).join(fa_index, by:[0,1])
    delly_bcf = DELLY_SV(delly_input)
    delly_index = DELLY_INDEX(delly_bcf)
    trf = TRF(haplotype_ch)
    severus_input = sorted_bam.join(trf, by: [0,1])
    severus_vcf = SEVERUS_SV(severus_input)
    clair_vcfs = CLAIRS_TO(clair_input)
    deepsomatic_bcf = DEEPSOMATIC(deepsomatic_input)
    consensusSV_input = delly_bcf.join(delly_index, by:[0,1]).join(severus_vcf, by:[0,1])
    consensus_SV = CONSENSUS_SV(consensusSV_input)
    SV_stats = SV_STATS(consensus_SV)
    consensusSNV_input = clair_vcfs.join(deepsomatic_bcf, by:[0,1])
    consensus_SNV = CONSENSUS_SNV(consensusSNV_input)
    varbridge_snv_input = consensus_SNV.join(sorted_grch38, by:[0,1]).join(sorted_chm13, by:[0,1])
    varbridge_sv_input = consensus_SV.join(sorted_grch38, by:[0,1])
    lifted_SNV = VARBRIDGE_SNV(varbridge_snv_input)
    lifted_SV = VARBRIDGE_SV(varbridge_sv_input)
    hap1_snv = lifted_SNV.filter { sample, hap,
                                   grch38_vcf, grch38_tbi, grch38_bed,
                                   chm13_vcf, chm13_tbi, chm13_bed ->
        hap == 1
    }

    hap2_snv = lifted_SNV.filter { sample, hap,
                                   grch38_vcf, grch38_tbi, grch38_bed,
                                   chm13_vcf, chm13_tbi, chm13_bed ->
        hap == 2
    }
    filter_varbridge_snv_input = hap1_snv.join(hap2_snv, by: 0)
    somatic_snv = FILTER_VARBRIDGE_SNV(filter_varbridge_snv_input)
    annotated_snv = VEP_SNV(somatic_snv)
    annotated_sv = VEP_SV(lifted_SV)
    if (params.genes) {
        filtered_snv = FILTER_SNV(annotated_snv)
        filtered_sv = FILTER_SV(annotated_sv)
    }

    emit:
    snv  = annotated_snv
    sv = annotated_sv
}
