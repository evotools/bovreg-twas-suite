process prepare_training_files {
  input:
    path(expr), path(covs)
  output:
    path("transformed_expression.txt"), path("covariates.txt")
  script:
    """
    cp $expr transformed_expression.txt
    cp $covs covariates.txt
    """
}
