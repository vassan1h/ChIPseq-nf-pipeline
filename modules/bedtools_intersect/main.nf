#!/usr/bin/env nextflow

process BEDTOOLS_INTERSECT {
    label 'process_low'
    conda 'envs/bedtools_env.yml'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple path(rep1_peaks), path(rep2_peaks)

    output:
    path("reproducible_peaks.bed"), emit: intersect

    shell:
    """
    bedtools intersect -a $rep1_peaks -b $rep2_peaks -f .5 -r > reproducible_peaks.bed
    """
}