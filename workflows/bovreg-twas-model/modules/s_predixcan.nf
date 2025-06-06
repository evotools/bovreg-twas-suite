process s_predixcan {
  input:
    path(weights_db), path(gwas_sumstats)
  output:
    path("s_predixcan_results.txt"), emit: result
  script:
    """
    python3 scripts/s_predixcan.py --model_db_path $weights_db --gwas_file $gwas_sumstats --output_file s_predixcan_results.txt
    """
}
