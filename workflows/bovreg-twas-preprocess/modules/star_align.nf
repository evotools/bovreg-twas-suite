#!/usr/bin/env nextflow

process star_align {
  tag "$sample_id"

  input:
    tuple val(sample_id), path(fq1), path(fq2), path(star_index)

  output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam
    tuple val(sample_id), path("${sample_id}.bam.bai"), emit: bai
    tuple val(sample_id), path("${sample_id}_Log.final.out"), emit: star_logs

  script:
    """
    STAR \
      --genomeDir ${star_index} \
      --readFilesIn ${fq1} ${fq2} \
      --readFilesCommand zcat \
      --runThreadN ${task.cpus} \
      --outSAMtype BAM SortedByCoordinate \
      --outFileNamePrefix ${sample_id}_

    mv ${sample_id}_Aligned.sortedByCoord.out.bam ${sample_id}.bam
    samtools index ${sample_id}.bam
    """
}