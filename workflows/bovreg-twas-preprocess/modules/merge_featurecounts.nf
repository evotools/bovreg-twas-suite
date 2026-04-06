#!/usr/bin/env nextflow

process merge_featurecounts {
  input:
    path(count_files)

  output:
    path("counts_matrix.tsv"), emit: matrix

  script:
    """
    python3 - << 'PY'
    import pandas as pd
    from pathlib import Path

    files = sorted(Path('.').glob('*_counts.txt'))
    if not files:
        raise SystemExit("No featureCounts files found")

    merged = None

    for fp in files:
        sample = fp.name.replace('_counts.txt', '')
        df = pd.read_csv(fp, sep='\\t', comment='#')
        if df.shape[1] < 7:
            raise SystemExit(f"Unexpected featureCounts format in {fp}")

        gene_col = df.columns[0]
        count_col = df.columns[-1]

        sub = df[[gene_col, count_col]].copy()
        sub.columns = ['Geneid', sample]

        if merged is None:
            merged = sub
        else:
            merged = merged.merge(sub, on='Geneid', how='outer')

    merged = merged.fillna(0)
    merged.to_csv('counts_matrix.tsv', sep='\\t', index=False)
    PY
    """
}