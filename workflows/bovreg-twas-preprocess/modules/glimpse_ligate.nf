#!/usr/bin/env nextflow

process glimpse_ligate {
  tag "$sample_id"

  input:
    tuple val(sample_id), val(phased_chunks)

  output:
    tuple val(sample_id), path("${sample_id}.imputed.bcf"), emit: imputed
    tuple val(sample_id), path("${sample_id}.imputed.bcf.csi"), emit: imputed_csi

  script:
    def chunk_list = phased_chunks
      .flatten()
      .collect { it.toString() }
      .sort()
      .join('\n')

    """
    cat > ${sample_id}.chunk_list.txt <<EOF
${chunk_list}
EOF

    GLIMPSE_ligate \
      --input ${sample_id}.chunk_list.txt \
      --output ${sample_id}.imputed.bcf

    bcftools index -f ${sample_id}.imputed.bcf
    """
}