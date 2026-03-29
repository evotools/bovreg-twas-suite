process merge_weights_to_sqlite {
  input:
    path(weights_files), path(model_summary_files), path(sample_info)
  output:
    path("weights.db"), emit: db
  script:
    """
    Rscript -e '
      library(RSQLite); library(dplyr)
      con <- dbConnect(SQLite(), "weights.db")
      read_many <- function(files) {
        dfs <- lapply(files, function(f) read.table(f, header=TRUE, sep="\\t", stringsAsFactors=FALSE, check.names=FALSE))
        bind_rows(dfs)
      }
      w <- read_many(strsplit("$weights_files", " ")[[1]])
      m <- read_many(strsplit("$model_summary_files", " ")[[1]])
      s <- read.table("$sample_info", header=TRUE, sep="\\t", stringsAsFactors=FALSE, check.names=FALSE)
      dbWriteTable(con, "weights", w)
      dbWriteTable(con, "model_summaries", m)
      dbWriteTable(con, "sample_info", s)
      dbDisconnect(con)
    '
    """
}
