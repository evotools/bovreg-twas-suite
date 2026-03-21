#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { parse_sample_sheet } from './modules/parse_sample_sheet.nf'
include { trim_galore } from './modules/trim_galore.nf'
include { fastqc } from './modules/fastqc.nf'
include { multiqc } from './modules/multiqc.nf'
include { star_index } from './modules/star_index.nf'
include { star_align } from './modules/star_align.nf'
include { featurecounts } from './modules/featurecounts.nf'
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

  peer_k = params.peer_k ?: 20

  parse_sample_sheet(sample_sheet_ch)

  // Parse sample tuples from parser output into (sample_id, fq1, fq2) for read-based modules.
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

  star_index(fasta_ch, gtf_ch)
  // Join each trimmed read pair with the shared STAR index directory.
  star_align(trimmed_reads_ch.combine(star_index.out.index).map { sample_id, fq1, fq2, idx ->
    tuple(sample_id, fq1, fq2, idx)
  })

  // Recover sample_id from BAM basename so featureCounts gets (sample_id, bam, gtf).
  bam_with_sample_ch = star_align.out.bam.map { bam ->
    tuple(bam.baseName, bam)
  }
  featurecounts(bam_with_sample_ch.combine(gtf_ch).map { sample_id, bam, gtf ->
    tuple(sample_id, bam, gtf)
  })

  kallisto_index(fasta_ch)
  // Join each trimmed read pair with the shared kallisto transcript index.
  kallisto_quant(trimmed_reads_ch.combine(kallisto_index.out.index).map { sample_id, fq1, fq2, idx ->
    tuple(sample_id, fq1, fq2, idx)
  })

  quantile_norm(featurecounts.out.counts)
  peer_factors(quantile_norm.out.norm, peer_k)

  mpileup_gls(star_align.out.bam.combine(fasta_ch).map { bam, fasta ->
    tuple(bam, fasta)
  })

  prepare_reference(panel_vcf_ch)
  // Keep reference and map together so GLIMPSE steps consume a stable (ref, map) pair.
  ref_map_ch = prepare_reference.out.ref.combine(map_file_ch).map { ref, map ->
    tuple(ref, map)
  }

  // Build GLIMPSE chunk inputs as (sample_vcf, reference_vcf, genetic_map).
  glimpse_chunk(mpileup_gls.out.bcf.combine(ref_map_ch).map { vcf, ref_map ->
    tuple(vcf, ref_map[0], ref_map[1])
  })

  // Create phase inputs as (chunk_file, sample_vcf, reference_vcf, genetic_map).
  phase_seed_ch = glimpse_chunk.out.chunks.combine(mpileup_gls.out.bcf).map { chunk, vcf ->
    tuple(chunk, vcf)
  }
  glimpse_phase(phase_seed_ch.combine(ref_map_ch).map { chunk_vcf, ref_map ->
    tuple(chunk_vcf[0], chunk_vcf[1], ref_map[0], ref_map[1])
  })
  glimpse_ligate(glimpse_phase.out.phased.collect())

  // Aggregate per-sample FastQC zips + STAR final logs into one MultiQC run.
  qc_artifacts_ch = fastqc.out.zip.flatten().mix(star_align.out.star_logs).collect()
  multiqc(qc_artifacts_ch)
}
