#!/usr/bin/env nextflow

process kallisto_index {
  input:
    path(fasta)

  output:
    path("kallisto.idx"), emit: index

  script:
    """
    kallisto index -i kallisto.idx ${fasta}
    """
}