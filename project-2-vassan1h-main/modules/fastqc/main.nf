#!usr/bin/env nextflow

process FASTQC{
    container "ghcr.io/bf528/fastqc:latest"
    label "process_single"
    publishDir params.outdir, mode: 'copy' 

    input:
    tuple val(sample_id), path(trimmed_reads)
    
    output:
    path('*.zip'), emit: zip
    path('*.html'), emit: html
    
    shell:
    """
    fastqc -t $task.cpus $trimmed_reads
    """
}