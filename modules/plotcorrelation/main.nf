process PLOTCORRELATION {
    container 'ghcr.io/bf528/deeptools:latest'
    
    input:
    path(matrix)

    output:
    path("spearman_heatmap.png"), emit: heatmap

    shell:
    """
    plotCorrelation -in $matrix -c spearman -p heatmap --plotNumbers --colorMap coolwarm -o spearman_heatmap.png
    """
}
