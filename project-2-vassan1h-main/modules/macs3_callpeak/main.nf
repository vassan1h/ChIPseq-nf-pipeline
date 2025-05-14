#!usr/bin/env nextflow

process MACS3_CALLPEAK {
    label 'process_medium'
    conda 'envs/macs3_env.yml'
    container 'ghcr.io/bf528/macs3:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(rep), path(IP), path(CONTROL)
    val(genome_size)

    output:
    tuple val(rep), path('*.narrowPeak'), emit: peaks

    shell:
    """
    macs3 callpeak \
        -t $IP \
        -c $CONTROL \
        -f BAM \
        -g $genome_size \
        -n $rep \
        --nomodel --extsize 200
    """
}
