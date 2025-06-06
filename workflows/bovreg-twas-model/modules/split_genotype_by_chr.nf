process split_genotype_by_chr {
  input:
    path(geno_file)
  output:
    path("genotype.chr*.txt"), emit: per_chr
  script:
    """
    for chr in {1..29}; do awk -v c=chr"$chr" '$1==c' $geno_file > genotype.chr$chr.txt; done
    """
}
