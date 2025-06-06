process parse_gtf {
  input:
    path(gtf)
  output:
    path("gene_annot.parsed.txt"), emit: parsed
  script:
    """
    awk '$3 == "gene" {print $0}' $gtf > gene_annot.parsed.txt
    """
}
