#!/usr/bin/env nextflow
process star_align {
  input:
    tuple val(sample_id), path(fq1), path(fq2), path(star_index)
  output:
    path("${sample_id}.bam"), emit: bam
  script:
    """
    STAR --genomeDir $star_index --readFilesIn $fq1 $fq2 \
         --runThreadN 4 --outSAMtype BAM SortedByCoordinate \
         --outFileNamePrefix ${sample_id}_ && \
    mv ${sample_id}_Aligned.sortedByCoord.out.bam ${sample_id}.bam
    """
}
