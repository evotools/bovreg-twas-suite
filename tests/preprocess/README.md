# Preprocess test assets (Linux cluster)

This folder contains lightweight templates for validating
`bovreg-twas-preprocess` on HPC.

## Files

- `samples.test.tsv`: 2-sample input sheet template.
- `params.test.json`: parameter file template used in test commands.

## How to use

1. Edit `samples.test.tsv` and replace FASTQ placeholders with real cluster paths.
2. Edit `params.test.json` and set valid paths for:
   - `fasta`
   - `gtf`
   - `panel_vcf`
   - `map_file`
3. Run the commands from the repository root:
   - `nextflow run workflows/bovreg-twas-preprocess -profile sge -stub-run -params-file tests/preprocess/params.test.json`
   - `nextflow run workflows/bovreg-twas-preprocess -profile sge -params-file tests/preprocess/params.test.json -resume`

## Notes

- The files here are templates only; no large reference/test data is committed.
- Override queue and cluster options as needed:
  - `--queue <queue_name>`
  - `--sge_penv smp`
  - `--sge_cluster_options '<scheduler options>'`
