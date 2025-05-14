#!usr/bin/env nextflow

process MULTIBIGWIGSUMMARY {
    container 'ghcr.io/bf528/deeptools:latest'

    input:
    path bigwigs
    val labels

    output:
    path 'bw_all.npz', emit: multibwsummary

    shell:
    """
    multiBigwigSummary bins \
        -b ${bigwigs.join(' ')} \
        --labels ${labels.join(' ')} \
        -o bw_all.npz \
        -p $task.cpus
    """
}
