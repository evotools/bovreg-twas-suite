process prepare_training_files {
  input:
    path(expr), path(covs)
  output:
    path("transformed_expression.txt"), emit: expr
    path("covariates.txt"), emit: covs
  script:
    """
    cp $expr transformed_expression.txt
    cp $covs covariates.txt
    """
}
