process s_predixcan {
  input:
    tuple val(trait), path(gwas_sumstats), path(weights_db)
  output:
    tuple val(trait), path("s_predixcan_results_${trait}.tsv"), emit: result
  script:
    """
    python3 ${projectDir}/scripts/s_predixcan.py \
      --model_db_path $weights_db \
      --gwas_file $gwas_sumstats \
      --trait $trait \
      --output_file s_predixcan_results_${trait}.tsv
    """
}
