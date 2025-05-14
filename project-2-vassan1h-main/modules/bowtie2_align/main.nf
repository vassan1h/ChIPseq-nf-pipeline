#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {
    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(trimmed_reads)
    path (bowtie2_index)
    val (name)

    output:
    tuple val(meta), path("${meta}.bam"), emit: bam


    shell:
    """
    bowtie2 --very-fast -p 15 -x $bowtie2_index/$name -U $trimmed_reads | samtools view -bS - > ${meta}.bam
    """
}