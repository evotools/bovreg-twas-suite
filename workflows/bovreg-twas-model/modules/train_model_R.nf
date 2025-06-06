process train_model_R {
  tag "chr${chrom}"

  input:
    val chrom
    path r_script

  output:
    path("Model_training_chr${chrom}_model_summaries.txt"), emit: model_summary
    path("Model_training_chr${chrom}_weights.txt"), emit: weights
    path("Model_training_chr${chrom}_covariances.txt"), emit: covariances

  script:
    """
    mkdir -p summary weights covariances
    Rscript ${r_script} \\
      output/snp_annot.chr${chrom}.txt \\
      output/gene_annot.parsed.txt \\
      output/genotype.chr${chrom}.txt \\
      output/transformed_expression.txt \\
      output/covariates.txt \\
      ${chrom} \\
      Model_training
    """
}

