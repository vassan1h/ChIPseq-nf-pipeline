#!/usr/bin/env nextflow

process HOMER_ANNOTATE {
    label 'process_low'
    conda 'envs/homer_env.yml'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(peaks)
    path(genome)
    path(gtf)

    output:
    path('annotated_peaks.txt')

    shell:
    """
    annotatePeaks.pl $peaks $genome -gtf $gtf > annotated_peaks.txt
    """
}
