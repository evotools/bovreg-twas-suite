#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { parse_sample_sheet } from './modules/parse_sample_sheet.nf'
include { trim_galore } from './modules/trim_galore.nf'
include { fastqc } from './modules/fastqc.nf'
include { multiqc } from './modules/multiqc.nf'
include { star_index } from './modules/star_index.nf'
include { star_align } from './modules/star_align.nf'
include { featurecounts } from './modules/featurecounts.nf'
include { merge_featurecounts } from './modules/merge_featurecounts.nf'
include { kallisto_index } from './modules/kallisto_index.nf'
include { kallisto_quant } from './modules/kallisto_quant.nf'
include { quantile_norm } from './modules/quantile_norm.nf'
include { mpileup_gls } from './modules/mpileup_gls.nf'
include { prepare_reference } from './modules/prepare_reference.nf'
include { glimpse_chunk } from './modules/glimpse_chunk.nf'
include { glimpse_phase } from './modules/glimpse_phase.nf'
include { glimpse_ligate } from './modules/glimpse_ligate.nf'
include { peer_factors } from './modules/peer_factors.nf'

workflow preprocess {

  Channel
    .fromPath(params.input_sheet, checkIfExists: true)
    .set { sample_sheet_ch }

  Channel
    .fromPath(params.fasta, checkIfExists: true)
    .set { fasta_ch }

  Channel
    .fromPath(params.gtf, checkIfExists: true)
    .set { gtf_ch }

  Channel
    .fromPath(params.panel_vcf, checkIfExists: true)
    .set { panel_vcf_ch }

  Channel
    .fromPath(params.map_file, checkIfExists: true)
    .set { map_file_ch }

  def peer_k = params.peer_k ?: 20

  parse_sample_sheet(sample_sheet_ch)

  sample_reads_ch = parse_sample_sheet.out.parsed
    .splitText()
    .filter { row -> row?.trim() }
    .map { row ->
      def match = (row.trim() =~ /\('([^']*)',\s*'[^']*',\s*'([^']*)',\s*'([^']*)'\)/)
      if( !match.matches() ) {
        throw new IllegalArgumentException("Unable to parse sample row: ${row}")
      }
      tuple(match[0][1], file(match[0][2]), file(match[0][3]))
    }

  trim_galore(sample_reads_ch)
  trimmed_reads_ch = trim_galore.out

  fastqc(trimmed_reads_ch)

  star_index(
    fasta_ch
      .combine(gtf_ch)
      .map { row ->
        tuple(row[0], row[1])
      }
  )

  star_align(
    trimmed_reads_ch
      .combine(star_index.out.index)
      .map { row ->
        tuple(row[0], row[1], row[2], row[3])
      }
  )

  bam_with_sample_ch = star_align.out.bam

  featurecounts_input_ch = bam_with_sample_ch
    .combine(gtf_ch)
    .map { sample_id, bam, gtf ->
      tuple(sample_id, bam, gtf)
    }

  featurecounts(featurecounts_input_ch)

  merge_featurecounts(
    featurecounts.out.counts
      .map { row -> row[1] }
      .collect()
  )

  kallisto_index(fasta_ch)

  kallisto_quant(
    trimmed_reads_ch
      .combine(kallisto_index.out.index)
      .map { row ->
        tuple(row[0], row[1], row[2], row[3])
      }
  )

  quantile_norm(merge_featurecounts.out.matrix)

  peer_factors(
    quantile_norm.out.norm
      .map { expr ->
        tuple(expr, peer_k)
      }
  )

  mpileup_input_ch = bam_with_sample_ch
    .combine(fasta_ch)
    .map { row ->
      tuple(row[0], row[1], row[2])
    }

  mpileup_gls(mpileup_input_ch)

  prepare_reference(panel_vcf_ch)

  glimpse_chunk_input_ch = mpileup_gls.out.bcf
    .map { sample_id, gl_bcf ->
      tuple(sample_id, gl_bcf)
  }

  glimpse_chunk(glimpse_chunk_input_ch)

  glimpse_phase_input_ch = glimpse_chunk.out.chunks
    .join(mpileup_gls.out.bcf)
    .combine(prepare_reference.out.ref)
    .combine(map_file_ch)
    .map { sample_id, chunk_file, gl_bcf, ref_file, ref_index, map_file ->
      tuple(sample_id, chunk_file, gl_bcf, ref_file, ref_index, map_file)
  }

  glimpse_phase(glimpse_phase_input_ch)

  phased_grouped_ch = glimpse_phase.out.phased
    .groupTuple()

  glimpse_ligate(phased_grouped_ch)
  
  star_log_files_ch = star_align.out.star_logs
    .map { row -> row[1] }

  fastqc_zip_files_ch = fastqc.out.zip
    .map { row -> row[1] }
    .flatten()

  qc_artifacts_ch = fastqc_zip_files_ch
    .mix(star_log_files_ch)
    .collect()

  multiqc(qc_artifacts_ch)
}

workflow {
  preprocess()
}