#!/usr/bin/env nextflow

include { FASTQC } from './modules/fastqc/main.nf'
include { TRIMMOMATIC } from './modules/trimmomatic/main.nf'
include { BOWTIE2_BUILD } from './modules/bowtie2_build/main.nf'
include { BOWTIE2_ALIGN } from './modules/bowtie2_align/main.nf'
include { SAMTOOLS_SORT } from './modules/samtools_sort/main.nf'
include { SAMTOOLS_IDX } from './modules/samtools_idx/main.nf'
include { SAMTOOLS_FLAGSTAT } from './modules/samtools_flagstat/main.nf'
include { BAMCOVERAGE } from './modules/deeptools_bamcoverage/main.nf'
include { MULTIQC } from './modules/multiqc/main.nf'
include { MULTIBIGWIGSUMMARY } from './modules/multibigwigsummary/main.nf'
include { PLOTCORRELATION } from './modules/plotcorrelation/main.nf'
include { MACS3_CALLPEAK } from './modules/macs3_callpeak/main.nf'
include { BEDTOOLS_INTERSECT } from './modules/bedtools_intersect/main.nf'
include { FILTER } from './modules/bedtools_blacklist_filter/main.nf'
include { HOMER_ANNOTATE } from './modules/homer_annotate/main.nf'
include { COMPUTEMATRIX } from './modules/deeptools_computematrix/main.nf'
include { PLOTPROFILE } from './modules/deeptools_plotprofile/main.nf'
include { FIND_MOTIFS } from './modules/homer_findmotifs/main.nf'


workflow {// Reproducible peaks
    reproducible_input = Channel.of(tuple(file(params.rep1), file(params.rep2)))
    | view()
    
    reproducible = BEDTOOLS_INTERSECT(reproducible_input)

    // Blacklist filter
    filtered_peaks = FILTER(reproducible, file(params.blacklist))

    // Annotate peaks
    annotated = HOMER_ANNOTATE(filtered_peaks, file(params.genome), file(params.annotation))

    // MultiQC input (collect logs)

}