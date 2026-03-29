process parse_gtf {
  input:
    path(gtf)
  output:
    path("gene_annot.parsed.txt"), emit: parsed
    path("gene_coords.tsv"), emit: coords
  script:
    """
    python3 - "$gtf" <<'PY'
import csv
import re
import sys

gtf_path = sys.argv[1]

with open("gene_annot.parsed.txt", "w", newline="") as out_main, open("gene_coords.tsv", "w", newline="") as out_coords:
    main_writer = csv.writer(out_main, delimiter="\t")
    coord_writer = csv.writer(out_coords, delimiter="\t")
    header = ["chr", "gene_type", "gene_id", "gene_name", "start", "end"]
    main_writer.writerow(header)
    coord_writer.writerow(header)

    with open(gtf_path, "r", encoding="utf-8") as handle:
        for line in handle:
            if not line or line.startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            if len(fields) < 9 or fields[2] != "gene":
                continue

            chrom = fields[0]
            start = fields[3]
            end = fields[4]
            attrs = fields[8]

            def get_attr(key):
                match = re.search(rf'{key} "([^"]+)"', attrs)
                return match.group(1) if match else ""

            gene_id = get_attr("gene_id")
            gene_name = get_attr("gene_name") or gene_id
            gene_type = get_attr("gene_type") or get_attr("gene_biotype")

            if not gene_id:
                continue

            row = [chrom, gene_type, gene_id, gene_name, start, end]
            main_writer.writerow(row)
            coord_writer.writerow(row)
PY
    """
}
