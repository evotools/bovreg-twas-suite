process split_snp_annot_by_chr {
  input:
    path(annot_file)
  output:
    path("snp_annot.chr*.txt"), emit: per_chr
  script:
    """
    for chr in {1..29}; do awk -v c=chr"$chr" '$2==c' $annot_file > snp_annot.chr$chr.txt; done
    """
}
