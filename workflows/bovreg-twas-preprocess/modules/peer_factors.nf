#!/usr/bin/env nextflow
process peer_factors {
  input:
    path(expr), val(n)
  output:
    path("peer_factors.tsv"), emit: factors
  script:
    """
    cat << EOF > run_peer.R
    library(peer)
    args <- commandArgs(trailingOnly = TRUE)
    expr_file <- args[1]
    n_factors <- as.integer(args[2])
    output_file <- args[3]
    expr_data <- read.table(expr_file, header = TRUE, row.names = 1)
    model <- PEER()
    PEER_setPhenoMean(model, as.matrix(t(expr_data)))
    PEER_setNk(model, n_factors)
    PEER_update(model)
    factors <- PEER_getX(model)
    write.table(factors, file = output_file, sep = "\t", quote = FALSE, col.names = NA)
EOF

    Rscript run_peer.R $expr $n peer_factors.tsv
    """
}
