#!/usr/bin/env nextflow
process mpileup_gls {
  input:
    path(bam), path(fasta)
  output:
    path("gls.bcf"), emit: bcf
  script:
    """
    bcftools mpileup -Ou -f $fasta $bam | bcftools call -m -Ob -o gls.bcf
    """
}
