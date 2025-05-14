#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    
    label 'process_medium'
    conda 'envs/deeptools_env.yml'
    container 'ghcr.io/bf528/deeptools:latest'

    input:
    tuple val(meta), path(bw), path(bed)

    output:
    tuple val(meta), path('*.gz'), emit: matrix

    shell:
    """
    computeMatrix scale-regions \
          -S ${bw.join(' ')} \
          -R ${bed} \
          -b 2000 \
          -o ${meta}.gz    
    """

}