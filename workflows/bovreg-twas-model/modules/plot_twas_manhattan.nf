process plot_twas_manhattan {
  tag "${trait}"

  input:
    tuple val(trait), path(twas_result), path(gene_coords)
  output:
    path("twas_manhattan_${trait}.png"), emit: png
    path("twas_manhattan_${trait}.pdf"), emit: pdf
    path("twas_plot_manifest_${trait}.tsv"), emit: manifest
  script:
    """
    Rscript ${projectDir}/scripts/plot_twas_manhattan.R \
      --trait $trait \
      --twas $twas_result \
      --gene-coords $gene_coords \
      --out-prefix twas_manhattan_${trait} \
      --manifest twas_plot_manifest_${trait}.tsv
    """
}
