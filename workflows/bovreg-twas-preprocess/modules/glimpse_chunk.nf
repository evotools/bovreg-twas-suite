#!/usr/bin/env nextflow
process glimpse_chunk {
  input:
    path(vcf), path(ref), path(map)
  output:
    path("chunks.txt"), emit: chunks
  script:
    """
    GLIMPSE_chunk --input $vcf --region chr1 --output chunks.txt --map $map
    """
}
