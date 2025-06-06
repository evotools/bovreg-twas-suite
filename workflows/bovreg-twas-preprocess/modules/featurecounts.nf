#!/usr/bin/env nextflow
process featurecounts {
  tag "$sample_id"
  input:
    tuple val(sample_id), path(bam), path(gtf)
  output:
    path("${sample_id}_counts.txt"), emit: counts
  script:
    """
    featureCounts -T 4 -a $gtf -o ${sample_id}_counts.txt $bam
    """
}
