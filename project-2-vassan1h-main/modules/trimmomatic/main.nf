#!/usr/bin/env nextflow

process TRIMMOMATIC {
    label 'process_low'
    container 'ghcr.io/bf528/trimmomatic:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta}_trimmed.fastq.gz"), emit: trimmed
    tuple val(meta), path("*.log"), emit: log

    shell:
    """
    trimmomatic SE -threads ${task.cpus} $reads ${meta}_trimmed.fastq.gz ILLUMINACLIP:${params.adapter_fa}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 2> ${meta}_trimmed.log
    """
}
