#!/usr/bin/env nextflow

process FIND_MOTIFS {
    label 'process_low'
    conda 'envs/homer_env.yml'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(repr_filtered_peaks)
    path(genome)

    output:
    path('motifs/')

    shell:
    """
    findMotifsGenome.pl $repr_filtered_peaks $genome motifs/ -size 200 -mask
    """
}

