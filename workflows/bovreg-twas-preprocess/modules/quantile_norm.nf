#!/usr/bin/env nextflow
process quantile_norm {
  input:
    path(expr)
  output:
    path("quantile_normalized.tsv"), emit: norm
  script:
    """
    cat << EOF > quantile_norm.R
    quantile_normalize <- function(df) {
      ranked <- apply(df, 2, rank, ties.method = "min")
      sorted <- apply(df, 2, sort)
      mean_ranks <- apply(sorted, 1, mean)
      normalized <- apply(ranked, 2, function(r) mean_ranks[r])
      return(normalized)
    }
    args <- commandArgs(trailingOnly = TRUE)
    input_file <- args[1]
    output_file <- args[2]
    expr_data <- read.table(input_file, header = TRUE, row.names = 1)
    norm_matrix <- quantile_normalize(expr_data)
    colnames(norm_matrix) <- colnames(expr_data)
    rownames(norm_matrix) <- rownames(expr_data)
    write.table(norm_matrix, file = output_file, sep = "\t", quote = FALSE, col.names = NA)
EOF

    Rscript quantile_norm.R $expr quantile_normalized.tsv
    """
}
