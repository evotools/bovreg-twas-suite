#!/usr/bin/env nextflow

process glimpse_chunk {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(gl_bcf)

  output:
    tuple val(sample_id), path("${sample_id}.chunks.txt"), emit: chunks

  script:
    """
    if [ ! -f ${gl_bcf}.csi ] && [ ! -f ${gl_bcf}.tbi ]; then
      bcftools index -f ${gl_bcf}
    fi

    chrom=\$(bcftools index -s ${gl_bcf} | awk 'NR==1{print \$1}')
    if [ -z "\$chrom" ]; then
      echo "Could not determine chromosome from ${gl_bcf}" >&2
      exit 1
    fi

    GLIMPSE_chunk \
      --input ${gl_bcf} \
      --region \$chrom \
      --window-size 2000000 \
      --buffer-size 200000 \
      --output ${sample_id}.chunks.txt
    """
}