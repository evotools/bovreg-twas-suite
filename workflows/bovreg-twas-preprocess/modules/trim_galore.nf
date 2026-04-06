#!/usr/bin/env nextflow

process trim_galore {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(fq1), path(fq2)

  output:
    tuple val(sample_id), path("${sample_id}_R1.trimmed.fq.gz"), path("${sample_id}_R2.trimmed.fq.gz")

  script:
    """
    trim_galore --paired ${fq1} ${fq2} --cores ${task.cpus} -o .

    r1_file=\$(ls *_val_1.fq.gz)
    r2_file=\$(ls *_val_2.fq.gz)

    mv "\$r1_file" ${sample_id}_R1.trimmed.fq.gz
    mv "\$r2_file" ${sample_id}_R2.trimmed.fq.gz
    """
}
