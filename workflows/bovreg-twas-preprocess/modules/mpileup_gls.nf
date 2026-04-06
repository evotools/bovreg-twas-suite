#!/usr/bin/env nextflow

process mpileup_gls {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(bam), path(fasta)

  output:
    tuple val(sample_id), path("${sample_id}.gls.bcf"), emit: bcf
    tuple val(sample_id), path("${sample_id}.gls.bcf.csi"), emit: csi

  script:
    """
    bcftools mpileup -Ou -f ${fasta} ${bam} | \
      bcftools call -m -Ob -o ${sample_id}.gls.bcf

    bcftools index -f ${sample_id}.gls.bcf
    """
}