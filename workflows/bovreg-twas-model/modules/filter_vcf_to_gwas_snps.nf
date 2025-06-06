process filter_vcf_to_gwas_snps {
  input:
    path(vcf), path(gwas_snps)
  output:
    path("filtered.vcf.gz"), emit: vcf
  script:
    """
    bcftools view -R $gwas_snps $vcf -Oz -o filtered.vcf.gz
    tabix -p vcf filtered.vcf.gz
    """
}
