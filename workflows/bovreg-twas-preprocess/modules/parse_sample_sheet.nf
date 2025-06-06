#!/usr/bin/env nextflow
process parse_sample_sheet {
  input:
    path(sheet)
  output:
    path("samples.tsv"), emit: parsed
  script:
    """
    python3 bin/parse_sample_sheet.py $sheet > samples.tsv
    """
}
