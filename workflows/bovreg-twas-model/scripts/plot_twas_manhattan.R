#!/usr/bin/env Rscript

suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(readr))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 10) {
  stop("Expected arguments: --trait <name> --twas <file> --gene-coords <file> --out-prefix <prefix> --manifest <file>")
}

arg_map <- setNames(args[seq(2, length(args), 2)], args[seq(1, length(args), 2)])
trait <- arg_map[["--trait"]]
twas_file <- arg_map[["--twas"]]
coords_file <- arg_map[["--gene-coords"]]
out_prefix <- arg_map[["--out-prefix"]]
manifest_file <- arg_map[["--manifest"]]

if (is.na(trait) || is.na(twas_file) || is.na(coords_file) || is.na(out_prefix) || is.na(manifest_file)) {
  stop("Missing one or more required named arguments")
}

pick_col <- function(df, candidates) {
  cols <- colnames(df)
  lower_map <- setNames(cols, tolower(cols))
  for (candidate in candidates) {
    key <- tolower(candidate)
    if (key %in% names(lower_map)) {
      return(lower_map[[key]])
    }
  }
  return(NA_character_)
}

twas_df <- suppressMessages(read_tsv(twas_file, show_col_types = FALSE))
coords_df <- suppressMessages(read_tsv(coords_file, show_col_types = FALSE))

gene_col <- pick_col(twas_df, c("gene_id", "gene", "ensg_id", "gene_name"))
p_col <- pick_col(twas_df, c("pvalue", "p_value", "pval", "p", "pv", "p-value"))

if (is.na(gene_col) || is.na(p_col)) {
  stop("TWAS input must contain a gene id/name column and a p-value column")
}

twas_norm <- twas_df %>%
  transmute(
    trait = trait,
    gene_key = as.character(.data[[gene_col]]),
    pvalue = suppressWarnings(as.numeric(.data[[p_col]]))
  )

coords_norm <- coords_df %>%
  transmute(
    chr_raw = as.character(chr),
    gene_id = as.character(gene_id),
    gene_name = as.character(gene_name),
    start = suppressWarnings(as.numeric(start))
  )

plot_df <- twas_norm %>%
  left_join(coords_norm, by = c("gene_key" = "gene_id"))

missing_after_gene_id <- sum(is.na(plot_df$start))
if (missing_after_gene_id > 0) {
  fallback_df <- twas_norm %>%
    left_join(coords_norm, by = c("gene_key" = "gene_name"))
  plot_df <- plot_df %>%
    mutate(
      chr_raw = ifelse(is.na(chr_raw), fallback_df$chr_raw, chr_raw),
      gene_id = ifelse(is.na(gene_id), fallback_df$gene_id, gene_id),
      gene_name = ifelse(is.na(gene_name), fallback_df$gene_name, gene_name),
      start = ifelse(is.na(start), fallback_df$start, start)
    )
}

plot_df <- plot_df %>%
  mutate(
    chr = suppressWarnings(as.integer(gsub("^chr", "", chr_raw, ignore.case = TRUE))),
    pvalue = ifelse(is.na(pvalue) | pvalue <= 0 | pvalue > 1, NA_real_, pvalue),
    neglog10p = -log10(pvalue)
  ) %>%
  filter(!is.na(chr), !is.na(start), !is.na(neglog10p))

if (nrow(plot_df) == 0) {
  stop("No plottable rows after coordinate and p-value normalization")
}

chr_order <- sort(unique(plot_df$chr))
chr_bounds <- plot_df %>%
  group_by(chr) %>%
  summarise(chr_len = max(start, na.rm = TRUE), .groups = "drop") %>%
  arrange(chr) %>%
  mutate(chr_offset = lag(cumsum(chr_len), default = 0))

plot_df <- plot_df %>%
  left_join(chr_bounds, by = "chr") %>%
  mutate(
    bp_cum = start + chr_offset,
    chr_factor = factor(chr, levels = chr_order),
    chr_group = as.integer(chr_factor) %% 2
  )

axis_df <- plot_df %>%
  group_by(chr) %>%
  summarise(center = (min(bp_cum) + max(bp_cum)) / 2, .groups = "drop") %>%
  arrange(chr)

manhattan_plot <- ggplot(plot_df, aes(x = bp_cum, y = neglog10p, color = as.factor(chr_group))) +
  geom_point(size = 1.2, alpha = 0.8) +
  scale_color_manual(values = c("0" = "#3B528B", "1" = "#5DC863"), guide = "none") +
  scale_x_continuous(labels = axis_df$chr, breaks = axis_df$center) +
  labs(
    title = paste0("TWAS Manhattan plot: ", trait),
    x = "Chromosome",
    y = expression(-log[10](pvalue))
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(paste0(out_prefix, ".png"), manhattan_plot, width = 13, height = 6, dpi = 300)
ggsave(paste0(out_prefix, ".pdf"), manhattan_plot, width = 13, height = 6)

total_rows <- nrow(twas_norm)
plotted_rows <- nrow(plot_df)
dropped_rows <- total_rows - plotted_rows

manifest <- tibble(
  trait = trait,
  input_rows = total_rows,
  plotted_rows = plotted_rows,
  dropped_rows = dropped_rows,
  png = paste0(out_prefix, ".png"),
  pdf = paste0(out_prefix, ".pdf")
)

write_tsv(manifest, manifest_file)
