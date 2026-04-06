#!/usr/bin/env nextflow

process kallisto_quant {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(fq1), path(fq2), path(index)

  output:
    tuple val(sample_id), path("${sample_id}_abundance.tsv"), emit: quant
    tuple val(sample_id), path("${sample_id}_run_info.json"), emit: run_info

  script:
    """
    kallisto quant -i ${index} -o kallisto_${sample_id} ${fq1} ${fq2}

    mv kallisto_${sample_id}/abundance.tsv ${sample_id}_abundance.tsv
    mv kallisto_${sample_id}/run_info.json ${sample_id}_run_info.json
    """
}