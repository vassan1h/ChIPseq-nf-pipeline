#!/usr/bin/env nextflow

process SAMTOOLS_FLAGSTAT {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    path("*flagstat.txt"), emit: txt

    shell:
    """
    samtools flagstat $bam > ${meta}.flagstat.txt
    """
}
