Parameter documentation lives in each workflow schema.

## Model workflow parameters

See `workflows/bovreg-twas-model/nextflow_schema.json` for the full list.
Important parameters for TWAS Manhattan plotting:

- `gwas_vcf`: input VCF used by `filter_vcf_to_gwas_snps`
- `gwas_sumstats_file`: single TWAS/GWAS summary table
- `gwas_sumstats_files`: list of summary tables (multi-trait mode)
- `gwas_sumstats_glob`: glob for summary tables (multi-trait mode)
- `make_twas_plots`: enable/disable Manhattan plotting (`true` by default)
- `outdir_model`: base output directory for model artifacts
