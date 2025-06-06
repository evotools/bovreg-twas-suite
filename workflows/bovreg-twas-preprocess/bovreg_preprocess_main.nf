#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { parse_sample_sheet } from './modules/parse_sample_sheet.nf'
include { trim_galore } from './modules/trim_galore.nf'
include { fastqc } from './modules/fastqc.nf'
include { multiqc } from './modules/multiqc.nf'
include { star_index } from './modules/star_index.nf'
include { star_align } from './modules/star_align.nf'
include { featurecounts } from './modules/featurecounts.nf'
include { kallisto_quant } from './modules/kallisto_quant.nf'
include { quantile_norm } from './modules/quantile_norm.nf'
include { mpileup_gls } from './modules/mpileup_gls.nf'
include { prepare_reference } from './modules/prepare_reference.nf'
include { glimpse_chunk } from './modules/glimpse_chunk.nf'
include { glimpse_phase } from './modules/glimpse_phase.nf'
include { glimpse_ligate } from './modules/glimpse_ligate.nf'
include { peer_factors } from './modules/peer_factors.nf'

workflow preprocess {
  parse_sample_sheet()
  trim_galore()
  fastqc()
  multiqc()
  star_index()
  star_align()
  featurecounts()
  kallisto_quant()
  quantile_norm()
  mpileup_gls()
  prepare_reference()
  glimpse_chunk()
  glimpse_phase()
  glimpse_ligate()
  peer_factors()
}
