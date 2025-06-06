#!/usr/bin/env nextflow
process prepare_reference {
  input:
    path(panel_vcf)
  output:
    path("reference.vcf.gz"), emit: ref
  script:
    """
    bcftools norm -m -any -Oz -o reference.vcf.gz $panel_vcf
    tabix -p vcf reference.vcf.gz
    """
}
