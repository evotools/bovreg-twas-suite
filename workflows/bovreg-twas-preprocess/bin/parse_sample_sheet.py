#!/usr/bin/env python3
import csv, argparse
ap = argparse.ArgumentParser()
ap.add_argument('sheet')
args = ap.parse_args()
sep = ',' if args.sheet.endswith('.csv') else '\t'
with open(args.sheet) as fh:
    for r in csv.DictReader(fh, delimiter=sep):
        print(f"('{r.get('sample_id','')}', '{r.get('run_acc','')}', "
              f"'{r.get('fastq_1','')}', '{r.get('fastq_2','')}')")
