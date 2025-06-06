#!/usr/bin/env nextflow
process kallisto_quant {
  input:
    tuple val(sample_id), path(fq1), path(fq2), path(index)
  output:
    path("${sample_id}_abundance.tsv"), emit: quant
  script:
    """
    kallisto quant -i $index -o kallisto_$sample_id $fq1 $fq2
    mv kallisto_$sample_id/abundance.tsv ${sample_id}_abundance.tsv
    """
}
