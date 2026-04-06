#!/usr/bin/env nextflow

process featurecounts {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(bam), path(gtf)

  output:
    tuple val(sample_id), path("${sample_id}_counts.txt"), emit: counts
    tuple val(sample_id), path("${sample_id}_counts.txt.summary"), emit: summary

  script:
    """
    featureCounts \
      -T ${task.cpus} \
      -p \
      --countReadPairs \
      -a ${gtf} \
      -o ${sample_id}_counts.txt \
      ${bam}
    """
}