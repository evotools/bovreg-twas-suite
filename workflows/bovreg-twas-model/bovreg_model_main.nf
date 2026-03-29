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
include { plot_twas_manhattan } from './modules/plot_twas_manhattan.nf'

workflow model {
  Channel.fromPath(params.gwas_vcf, checkIfExists: true).set { gwas_vcf_ch }
  Channel.fromPath(params.gwas_snps, checkIfExists: true).set { gwas_snps_ch }
  Channel.fromPath(params.gtf, checkIfExists: true).set { gtf_ch }
  Channel.fromPath(params.genotype_file, checkIfExists: true).set { genotype_ch }
  Channel.fromPath(params.expression_file, checkIfExists: true).set { expression_ch }
  Channel.fromPath(params.covariates_file, checkIfExists: true).set { covariates_ch }
  Channel.fromPath(params.snp_annot_file, checkIfExists: true).set { snp_annot_ch }

  def selected_chroms = (params.chroms ?: (1..29)) as Set
  def model_prefix = params.model_prefix ?: 'Model_training'

  def gwas_list = []
  if (params.gwas_sumstats_file) gwas_list << params.gwas_sumstats_file
  if (params.gwas_sumstats_files) gwas_list.addAll(params.gwas_sumstats_files)
  if (gwas_list.isEmpty() && !params.gwas_sumstats_glob) {
    error "Provide TWAS/GWAS summary files using --gwas_sumstats_file, --gwas_sumstats_files, or --gwas_sumstats_glob"
  }

  gwas_sumstats_list_ch = gwas_list ? Channel.fromList(gwas_list).map { file(it) } : Channel.empty()
  gwas_sumstats_glob_ch = params.gwas_sumstats_glob ? Channel.fromPath(params.gwas_sumstats_glob, checkIfExists: true) : Channel.empty()
  gwas_sumstats_ch = gwas_sumstats_list_ch.mix(gwas_sumstats_glob_ch).unique()

  filter_vcf_to_gwas_snps(gwas_vcf_ch, gwas_snps_ch)
  split_genotype_by_chr(genotype_ch)
  split_snp_annot_by_chr(snp_annot_ch)
  parse_gtf(gtf_ch)
  prepare_training_files(expression_ch, covariates_ch)

  genotype_per_chr_ch = split_genotype_by_chr.out.per_chr
    .map { f ->
      def m = (f.baseName =~ /genotype\.chr(\d+)/)
      m.matches() ? tuple(m[0][1] as Integer, f) : null
    }
    .filter { it != null }
    .filter { chrom, _ -> chrom in selected_chroms }

  snp_annot_per_chr_ch = split_snp_annot_by_chr.out.per_chr
    .map { f ->
      def m = (f.baseName =~ /snp_annot\.chr(\d+)/)
      m.matches() ? tuple(m[0][1] as Integer, f) : null
    }
    .filter { it != null }
    .filter { chrom, _ -> chrom in selected_chroms }

  train_inputs_ch = snp_annot_per_chr_ch
    .join(genotype_per_chr_ch)
    .combine(parse_gtf.out.parsed)
    .combine(prepare_training_files.out.expr)
    .combine(prepare_training_files.out.covs)
    .combine(Channel.value(model_prefix))
    .combine(Channel.value(file("${projectDir}/scripts/train_elnet_nested_cv.R")))
    .map { chrom, snp_annot_file, genotype_file, gene_annot_file, expr_file, cov_file, prefix, r_script ->
      tuple(chrom, snp_annot_file, genotype_file, gene_annot_file, expr_file, cov_file, prefix, r_script)
    }

  train_model_R(train_inputs_ch)
  filter_models(train_model_R.out.model_summary.collect())

  merge_weights_to_sqlite(
    train_model_R.out.weights.collect(),
    train_model_R.out.model_summary.collect(),
    prepare_training_files.out.covs
  )

  trait_sumstats_ch = gwas_sumstats_ch.map { sumstats ->
    def trait = sumstats.baseName.replaceAll(/[^A-Za-z0-9_.-]/, "_")
    tuple(trait, sumstats)
  }

  s_predixcan_inputs_ch = trait_sumstats_ch
    .combine(merge_weights_to_sqlite.out.db)
    .map { trait, sumstats, weights_db ->
      tuple(trait, sumstats, weights_db)
    }
  s_predixcan(s_predixcan_inputs_ch)

  if (params.make_twas_plots == null || params.make_twas_plots) {
    plot_inputs_ch = s_predixcan.out.result
      .combine(parse_gtf.out.coords)
      .map { trait, twas_result, gene_coords ->
        tuple(trait, twas_result, gene_coords)
      }
    plot_twas_manhattan(plot_inputs_ch)
  }
}

