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
include { COMPUTEMATRIX as COMPUTEMATRIX_REP1 } from './modules/deeptools_computematrix/main.nf'
include { COMPUTEMATRIX as COMPUTEMATRIX_REP2 } from './modules/deeptools_computematrix/main.nf'
include { PLOTPROFILE } from './modules/deeptools_plotprofile/main.nf'
include { FIND_MOTIFS } from './modules/homer_findmotifs/main.nf'
include { PLOTPROFILE as MODULE_PLOTPROFILE } from './modules/deeptools_plotprofile/main.nf'


workflow {
    // Load samples from CSV; assumes single‑end FASTQ files
    sample_ch = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.name, file(row.path)) }

    // Trimmomatic to generate trimmed reads
    trimmed_ch = TRIMMOMATIC(sample_ch).trimmed

    // FASTQC on the trimmed reads
    trimmed_fastqc = FASTQC(trimmed_ch)

    // Build Bowtie2 index for the reference genome
    bowtie2 = BOWTIE2_BUILD(file(params.genome))

    // Align trimmed reads with Bowtie2 (single‑end)
    aligned_bams = BOWTIE2_ALIGN(trimmed_ch, bowtie2.index, bowtie2.name)

    // Sort and index the aligned BAM files
    sorted_bams = SAMTOOLS_SORT(aligned_bams)
    indexed_bams = sorted_bams

    // Compute alignment statistics with Samtools flagstat
    flagstat_out = SAMTOOLS_FLAGSTAT(indexed_bams)

    // Generate bigWig coverage files from the indexed BAMs
    bigwig_out = BAMCOVERAGE(indexed_bams)

    // Extract files and labels
    bw_files  = bigwig_out.map { it[1] }.collect()
    bw_labels = bigwig_out.map { it[0] }.collect()

    // Correlation analysis
    correlation_matrix = MULTIBIGWIGSUMMARY(bw_files, bw_labels)

    // If you want to try peakcalling by yourself using macs3
    // peakcalling_ch = BOWTIE2_ALIGN.out
     //   .map { name, path -> tuple(name.split('_')[1], [(path.baseName.split('_')[0]): path]) }
      //  .groupTuple(by: 0)
      //  .map { rep, maps -> tuple(rep, maps[0] + maps[1]) }
       // .map { rep, samples -> tuple(rep, samples.IP, samples.INPUT) }

    // Peak calling
    //peakcalls = MACS3_CALLPEAK(peakcalling_ch, Channel.value(params.genome_size))

    // Reproducible peaks
    reproducible_input = Channel.of(tuple(file(params.rep1), file(params.rep2)))
 
    reproducible = BEDTOOLS_INTERSECT(reproducible_input)

    // Blacklist filter
    filtered_peaks = FILTER(reproducible, file(params.blacklist))

    // Annotate peaks
    annotated = HOMER_ANNOTATE(filtered_peaks, file(params.genome), file(params.annotation))

    // Grab the FastQC ZIPs and the flagstat TXT files 
    fastqc_zips     = trimmed_fastqc.zip     
    flagstat_txts   = flagstat_out.txt        

    // Merge all QC files into one stream, then collect into a List<Path>
    qc_batch = fastqc_zips
                  .mix(flagstat_txts)
                  .collect()            

    // Run MultiQC
   MULTIQC(qc_batch)

   correlation_matrix.multibwsummary.set { multibw_file_ch }

    // For spearman plot correlation:
    PLOTCORRELATION(multibw_file_ch)

    indexed_bams
        .map { name, bam, bai -> 
        def rep = name.split('_')[1]
        def tag = bam.baseName.split('_')[0]  // "IP" or "INPUT"
        tuple(rep, [(tag): [bam, bai]])
    }
    .groupTuple(by: 0)
    .map { rep, maps -> tuple(rep, maps[0] + maps[1]) }
    .map { rep, samples -> tuple(rep, samples.IP[0], samples.IP[1], samples.INPUT[0], samples.INPUT[1]) }
    .set { peakcalling_ch }


// Inputs
    IP_rep1_bw    = file("/projectnb/bf528/students/vassanth/project-2-vassan1h/work/22/1d28397431255220b3cd768aaaf7f4/IP_rep1_coverage.bw")
    INPUT_rep1_bw = file("/projectnb/bf528/students/vassanth/project-2-vassan1h/work/d2/668f2e0b036c2cdee50416a34586ac/INPUT_rep1_coverage.bw")

    IP_rep2_bw    = file("/projectnb/bf528/students/vassanth/project-2-vassan1h/work/da/16f06057967c15017c6d8c95d7ec98/IP_rep2_coverage.bw")
    INPUT_rep2_bw = file("/projectnb/bf528/students/vassanth/project-2-vassan1h/work/3e/6dc24b61dcc70003cf4e2830fd33f7/INPUT_rep2_coverage.bw")


// Channels
    ch_rep1 = Channel.of( tuple("rep1", [IP_rep1_bw, INPUT_rep1_bw], file(params.annotation)) )
    ch_rep2 = Channel.of( tuple("rep2", [IP_rep2_bw, INPUT_rep2_bw], file(params.annotation)) )
    ch_reps = ch_rep1.concat(ch_rep2)
    .view()

// Compute matrix
    matrix1 = COMPUTEMATRIX_REP1(ch_reps)

// Plot
    plot1 = PLOTPROFILE(matrix1)

    matrix = COMPUTEMATRIX_REP2(bigwig_out, filtered_peaks)
    profile_plot = PLOTPROFILE(matrix)
    motifs = FIND_MOTIFS(filtered_peaks, file(params.genome))
    //.view()

}