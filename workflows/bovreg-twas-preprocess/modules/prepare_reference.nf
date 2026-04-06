#!/usr/bin/env nextflow

process prepare_reference {
  input:
    path(panel_vcf)

  output:
    tuple path("reference.bcf"), path("reference.bcf.csi"), emit: ref

  script:
    """
    cp ${panel_vcf} reference.bcf
    if [ -f ${panel_vcf}.csi ]; then
      cp ${panel_vcf}.csi reference.bcf.csi
    else
      bcftools index -f reference.bcf
    fi
    """
}
