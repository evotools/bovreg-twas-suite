#!/usr/bin/env nextflow
process fastqc {
  tag "$sample_id"
  input:
    tuple val(sample_id), path(fq1), path(fq2)
  output:
    path("${sample_id}_fastqc.zip"), emit: zip
  script:
    """
    fastqc -o . $fq1 $fq2
    """
}
