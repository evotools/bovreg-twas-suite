#!/usr/bin/env nextflow

process glimpse_phase {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(chunk_file), path(gl_bcf), path(ref_file), path(ref_index), path(map_file)

  output:
    tuple val(sample_id), path("${sample_id}.phased_chunk_*.bcf"), emit: phased

  script:
    """
    if [ ! -f ${gl_bcf}.csi ] && [ ! -f ${gl_bcf}.tbi ]; then
      bcftools index -f ${gl_bcf}
    fi

    i=0
    while IFS="" read -r line || [ -n "\$line" ]; do
      i=\$((i+1))
      printf -v IDX "%03d" "\$i"

      IRG=\$(echo "\$line" | awk '{print \$3}')
      ORG=\$(echo "\$line" | awk '{print \$4}')

      if [ -z "\$IRG" ] || [ -z "\$ORG" ]; then
        echo "Malformed chunk line: \$line" >&2
        exit 1
      fi

      GLIMPSE_phase \
        --input ${gl_bcf} \
        --input-region "\$IRG" \
        --reference ${ref_file} \
        --map ${map_file} \
        --output-region "\$ORG" \
        --output ${sample_id}.phased_chunk_\${IDX}.bcf

      bcftools index -f ${sample_id}.phased_chunk_\${IDX}.bcf
    done < ${chunk_file}
    """
}