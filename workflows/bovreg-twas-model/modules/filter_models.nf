process filter_models {
  input:
    path(model_summaries)
  output:
    path("filtered_models.txt"), emit: filtered
  script:
    """
    awk '$12 < 0.05 && $14 > 0.1' $model_summaries > filtered_models.txt
    """
}
