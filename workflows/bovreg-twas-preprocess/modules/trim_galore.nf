#!/usr/bin/env nextflow
process trim_galore {
  tag "$sample_id"
  input:
    tuple val(sample_id), path(fq1), path(fq2)
  output:
    tuple val(sample_id), path("${sample_id}_R1.trimmed.fq.gz"), path("${sample_id}_R2.trimmed.fq.gz")
  script:
    """
    trim_galore --paired $fq1 $fq2 -o .
    mv *_val_1.fq.gz ${sample_id}_R1.trimmed.fq.gz
    mv *_val_2.fq.gz ${sample_id}_R2.trimmed.fq.gz
    """
}
