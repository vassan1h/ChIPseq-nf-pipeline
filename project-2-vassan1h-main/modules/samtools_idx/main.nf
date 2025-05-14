#!/usr/bin/env nextflow

process SAMTOOLS_IDX {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(sortedBam)

    output:
    tuple val(meta), path("${meta}.sorted.bam"), path("${meta}.sorted.bam.bai"), emit: index

    shell:
    """
    samtools index --threads $task.cpus $sortedBam
    """
}