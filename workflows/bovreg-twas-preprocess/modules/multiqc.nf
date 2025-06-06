#!/usr/bin/env nextflow
process multiqc {
  input:
    path("*.zip")
  output:
    path("multiqc_report.html"), emit: report
  script:
    """
    multiqc . -o .
    """
}
