#!/usr/bin/env nextflow

process SAMTOOLS_SORT {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*sorted.bam"), path("*sorted.bam.bai")
    
    shell:
    """
    samtools sort -@ $task.cpus $bam > ${meta}.sorted.bam
    samtools index -@ $task.cpus ${meta}.sorted.bam
    """
}