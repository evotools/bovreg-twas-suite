#!/usr/bin/env nextflow

process multiqc {
  input:
    path(qc_files)

  output:
    path("multiqc_report.html"), emit: report
    path("multiqc_data"), emit: data

  script:
    """
    multiqc . -o .
    """
}