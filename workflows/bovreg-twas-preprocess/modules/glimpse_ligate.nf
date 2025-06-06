#!/usr/bin/env nextflow
process glimpse_ligate {
  input:
    path("*.vcf.gz")
  output:
    path("imputed.vcf.gz"), emit: imputed
  script:
    """
    GLIMPSE_ligate --input . --output imputed.vcf.gz
    """
}
