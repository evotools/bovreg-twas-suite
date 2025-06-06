process star_index {
  input:
    path(fasta), path(gtf)
  output:
    path("star_index"), emit: index  // no trailing slash
  script:
    """
    mkdir -p star_index
    STAR --runThreadN 4 --runMode genomeGenerate \
         --genomeDir star_index \
         --genomeFastaFiles $fasta \
         --sjdbGTFfile $gtf \
         --sjdbOverhang 100
    """
}

