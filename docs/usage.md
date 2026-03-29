## Usage

Refer to `README.md` for primary run examples.

## Linux cluster smoke test (SGE + conda)

From repository root:

```bash
nextflow config workflows/bovreg-twas-preprocess -profile sge
nextflow run workflows/bovreg-twas-preprocess -profile sge -stub-run -params-file tests/preprocess/params.test.json
nextflow run workflows/bovreg-twas-preprocess -profile sge -params-file tests/preprocess/params.test.json -resume
```

Expected MultiQC report path:

`results/multiqc/multiqc_report.html`
