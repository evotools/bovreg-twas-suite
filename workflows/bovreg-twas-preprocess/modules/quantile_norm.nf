#!/usr/bin/env nextflow

process quantile_norm {
  input:
    path(expr)

  output:
    path("quantile_normalized.tsv"), emit: norm

  script:
    """
    cat << 'EOF' > quantile_norm.R
    quantile_normalize <- function(mat) {
      ranks <- apply(mat, 2, rank, ties.method = "min")
      sorted <- apply(mat, 2, sort)
      mean_sorted <- rowMeans(sorted)
      norm <- apply(ranks, 2, function(r) mean_sorted[r])
      norm <- as.matrix(norm)
      return(norm)
    }

    args <- commandArgs(trailingOnly = TRUE)
    input_file <- args[1]
    output_file <- args[2]

    expr_data <- read.table(input_file, header = TRUE, sep = "\\t", check.names = FALSE)
    rownames(expr_data) <- expr_data[,1]
    expr_data <- expr_data[,-1, drop = FALSE]

    expr_data <- as.matrix(expr_data)
    storage.mode(expr_data) <- "numeric"

    norm_matrix <- quantile_normalize(expr_data)
    colnames(norm_matrix) <- colnames(expr_data)
    rownames(norm_matrix) <- rownames(expr_data)

    write.table(
      cbind(Geneid = rownames(norm_matrix), norm_matrix),
      file = output_file,
      sep = "\\t",
      quote = FALSE,
      row.names = FALSE
    )
    EOF

    Rscript quantile_norm.R ${expr} quantile_normalized.tsv
    """
}