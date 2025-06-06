#!/usr/bin/env nextflow
process glimpse_phase {
  input:
    path(chunk), path(vcf), path(ref), path(map)
  output:
    path("*.vcf.gz"), emit: phased
  script:
    """
    GLIMPSE_phase --input $vcf --reference $ref --map $map --output phased_chr.vcf.gz
    """
}
