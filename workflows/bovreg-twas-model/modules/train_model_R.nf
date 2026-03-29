process train_model_R {
  tag "chr${chrom}"

  input:
    tuple val(chrom), path(snp_annot), path(genotype), path(gene_annot), path(expression), path(covariates), val(model_prefix), path(r_script)

  output:
    path("${model_prefix}_chr${chrom}_model_summaries.txt"), emit: model_summary
    path("${model_prefix}_chr${chrom}_weights.txt"), emit: weights
    path("${model_prefix}_chr${chrom}_covariances.txt"), emit: covariances

  script:
    """
    Rscript ${r_script} \\
      $snp_annot \\
      $gene_annot \\
      $genotype \\
      $expression \\
      $covariates \\
      ${chrom} \\
      ${model_prefix}
    """
}

