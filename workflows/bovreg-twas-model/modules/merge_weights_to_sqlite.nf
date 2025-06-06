process merge_weights_to_sqlite {
  input:
    path(weights), path(model_summaries), path(sample_info)
  output:
    path("weights.db"), emit: db
  script:
    """
    Rscript -e '
      library(RSQLite); library(dplyr)
      con <- dbConnect(SQLite(), "weights.db")
      w <- read.table("$weights", header=TRUE)
      m <- read.table("$model_summaries", header=TRUE)
      s <- read.table("$sample_info", header=TRUE)
      dbWriteTable(con, "weights", w)
      dbWriteTable(con, "model_summaries", m)
      dbWriteTable(con, "sample_info", s)
      dbDisconnect(con)
    '
    """
}
