#!/usr/bin/env nextflow

process FILTER {
    label 'process_low'
    conda 'envs/bedtools_env.yml'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(rep1_peaks)
    path(blacklist)

    output:
    path("filtered_peaks.bed"), emit: filtered

    shell:
    """
    bedtools intersect -a $rep1_peaks -b $blacklist -v > filtered_peaks.bed
    """
}