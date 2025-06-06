# 🐄 bovreg-twas-suite

`bovreg-twas-suite` is a modular Nextflow pipeline suite for performing transcriptome-wide association studies (TWAS) in cattle. It includes workflows to generate imputed genotypes and expression inputs from RNA-seq data for model training, and to run TWAS using trained models to map trait-associated genes.

It comprises two independent workflows:

| Workflow                  | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `bovreg-twas-preprocess`  | Preprocess RNA-seq and genotype data — includes trimming, alignment, quantification, imputation, and PEER factor inference |
| `bovreg-twas-model`       | Train elastic net gene expression prediction models and run S-PrediXcan |

---

## 📦 Installation

Clone the repository:

```bash
git clone https://github.com/siddharthjayaraman/bovreg-twas-suite.git
cd bovreg-twas-suite
```

Ensure you have:
- [Nextflow](https://www.nextflow.io/) v22.10.0 or higher
- Either: Conda, Docker, or Singularity
- Reference genome files, annotation, and optionally a GWAS SNP list

---

## 🛠 Workflow Overview

### 1️⃣ Preprocessing Workflow: `bovreg-twas-preprocess`

Runs:
- `trim_galore`, `fastqc`, `star`, `featureCounts`, `kallisto`
- `GLIMPSE` phasing and imputation
- PEER factor estimation

#### Run example:
```bash
nextflow run workflows/bovreg-twas-preprocess \
  --fasta cattle.fa \
  --gtf annotation.gtf \
  --input_sheet samples.tsv \
  --panel_vcf reference_panel.vcf.gz \
  --map_file genetic_map.txt \
  -profile conda
```

> Use `-stub-run` to validate structure.

---

### 2️⃣ Model Workflow: `bovreg-twas-model`

Runs:
- VCF and SNP annotation filtering
- Training of elastic net models using nested CV
- Covariance matrix computation
- Merging results into SQLite
- Running `S-PrediXcan`

#### Run example:
```bash
nextflow run workflows/bovreg-twas-model \
  --gwas_snps gwas_snps.txt \
  --gtf annotation.gtf \
  --genotype_file genotypes.txt \
  --expression_file expression.txt \
  --covariates_file covariates.txt \
  --snp_annot_file snp_annot.txt \
  -profile conda
```

---

## 🔎 Parameters

Each workflow includes a `nextflow_schema.json` so you can explore parameters with:

```bash
nextflow run workflows/bovreg-twas-preprocess --help
nextflow run workflows/bovreg-twas-model --help
```

---

## 🧪 Testing

You can validate the full structure using:

```bash
nextflow run workflows/bovreg-twas-preprocess -stub-run
nextflow run workflows/bovreg-twas-model -stub-run
```

---

## 📁 Folder Structure

```
workflows/
├── bovreg-twas-preprocess/
│   ├── main.nf
│   ├── modules/
│   ├── nextflow.config
│   └── nextflow_schema.json
├── bovreg-twas-model/
│   ├── main.nf
│   ├── modules/
│   ├── scripts/
│   ├── nextflow.config
│   └── nextflow_schema.json
configs/           → Profiles for HPC or containerised execution
envs/              → Conda YAMLs for each module group
bin/               → Custom scripts (e.g., parse_sample_sheet.py)
```

---

## ✨ Authors

Developed by [Siddharth Jayaraman](https://github.com/siddharthjayaraman) for the BovReg project.  
Includes contributions from Roslin Institute pipelines and PredictDB modeling strategies.

---

## 📝 License

MIT License. See `LICENSE` for full text.