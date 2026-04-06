#!/usr/bin/env nextflow

process fastqc {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(fq1), path(fq2)

  output:
    tuple val(sample_id), path("*_fastqc.zip"), emit: zip
    tuple val(sample_id), path("*_fastqc.html"), emit: html

  script:
    """
    fastqc -o . ${fq1} ${fq2}
    """
}
