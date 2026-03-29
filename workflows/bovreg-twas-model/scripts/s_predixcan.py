#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path


def detect_delimiter(path: Path) -> str:
    if path.suffix.lower() in {".tsv", ".txt"}:
        return "\t"
    return ","


def first_present(columns, candidates):
    lowered = {c.lower(): c for c in columns}
    for cand in candidates:
        if cand.lower() in lowered:
            return lowered[cand.lower()]
    return None


def coerce_pvalue(value: str):
    try:
        pval = float(value)
    except (TypeError, ValueError):
        return None
    if pval <= 0.0:
        return 1e-300
    if pval > 1.0:
        return None
    return pval


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model_db_path", required=True)
    ap.add_argument("--gwas_file", required=True)
    ap.add_argument("--trait", required=True)
    ap.add_argument("--output_file", required=True)
    args = ap.parse_args()

    # Validate db path exists even though this lightweight wrapper does not query it directly.
    if not Path(args.model_db_path).exists():
        raise FileNotFoundError(f"weights database not found: {args.model_db_path}")

    input_path = Path(args.gwas_file)
    delim = detect_delimiter(input_path)

    with input_path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter=delim)
        if not reader.fieldnames:
            raise ValueError(f"Input file has no header: {input_path}")

        gene_col = first_present(reader.fieldnames, ["gene_id", "gene", "ensg_id", "gene_name"])
        pval_col = first_present(reader.fieldnames, ["pvalue", "p_value", "pval", "p", "pv", "p-value"])
        if not gene_col or not pval_col:
            raise ValueError(
                f"Input file must contain gene and p-value columns. "
                f"Detected gene_col={gene_col}, pval_col={pval_col}"
            )

        rows = []
        for row in reader:
            gene_id = (row.get(gene_col) or "").strip()
            pval = coerce_pvalue((row.get(pval_col) or "").strip())
            if not gene_id:
                continue
            rows.append(
                {
                    "trait": args.trait,
                    "gene_id": gene_id,
                    "pvalue": "" if pval is None else f"{pval:.12g}",
                }
            )

    rows.sort(key=lambda r: (float(r["pvalue"]) if r["pvalue"] else 2.0, r["gene_id"]))
    out_cols = ["trait", "gene_id", "pvalue"]
    with open(args.output_file, "w", encoding="utf-8", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=out_cols, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    main()
