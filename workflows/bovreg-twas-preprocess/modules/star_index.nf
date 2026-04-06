#!/usr/bin/env nextflow

process star_index {
  input:
    tuple path(fasta), path(gtf)

  output:
    path("star_index"), emit: index

  script:
    """
    mkdir -p star_index

    STAR \
      --runThreadN ${task.cpus} \
      --runMode genomeGenerate \
      --genomeDir star_index \
      --genomeFastaFiles ${fasta} \
      --sjdbGTFfile ${gtf} \
      --sjdbOverhang 100
    """
}
