Outputs are written under `results/` (preprocess) and `results_model/` (model).

Model workflow key outputs:

- `results_model/s_predixcan/s_predixcan_results_<trait>.tsv`
  - Normalized per-trait TWAS/S-PrediXcan table with at least:
    - `trait`
    - `gene_id`
    - `pvalue`
- `results_model/twas_plots/twas_manhattan_<trait>.png`
- `results_model/twas_plots/twas_manhattan_<trait>.pdf`
- `results_model/twas_plots/twas_plot_manifest_<trait>.tsv`
  - Per-trait plotting summary:
    - `input_rows`
    - `plotted_rows`
    - `dropped_rows`
