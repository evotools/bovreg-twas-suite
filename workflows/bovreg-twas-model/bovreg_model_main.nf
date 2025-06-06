#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { filter_vcf_to_gwas_snps } from './modules/filter_vcf_to_gwas_snps.nf'
include { split_genotype_by_chr } from './modules/split_genotype_by_chr.nf'
include { split_snp_annot_by_chr } from './modules/split_snp_annot_by_chr.nf'
include { parse_gtf } from './modules/parse_gtf.nf'
include { prepare_training_files } from './modules/prepare_training_files.nf'
include { train_model_R } from './modules/train_model_R.nf'
include { filter_models } from './modules/filter_models.nf'
include { merge_weights_to_sqlite } from './modules/merge_weights_to_sqlite.nf'
include { s_predixcan } from './modules/s_predixcan.nf'

  Channel.from(1..29).set { chroms }
  chroms.map { chrom -> tuple(chrom, file("scripts/train_elnet_nested_cv.R")) } | train_model_R
  
  // Declare the R script path
  R_SCRIPT = file("scripts/train_elnet_nested_cv.R")

  filter_vcf_to_gwas_snps()
  split_genotype_by_chr()
  split_snp_annot_by_chr()
  parse_gtf()
  prepare_training_files()

  // Pass script into the model training

  filter_models()
  merge_weights_to_sqlite()
  s_predixcan()
}

