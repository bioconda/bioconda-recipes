#! /usr/bin/env python3
""" Quick hacky script that shows bias by gene length from a csv from gene_wise_evaluation.py in
a debugger. Divides the genes into somewhat exponentially growing buckets.

dfg will show the bias while dfgc will show the bucket counts.
"""

import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-p', '--path', type=str, required=True, default='alternative_splicing_results.csv')
args = parser.parse_args()

df = pd.read_csv(args.path, sep=',',
                 names=['seqid', 'strand', 'start', 'end', 'gene_name', 'n_transcripts',
                        'ig_f1', 'utr_f1', 'intron_f1', 'exon_f1', 'sub_genic_f1', 'genic_f1'])
df['length_bin'] = pd.cut((df.start - df.end).abs(),
                           bins=[0, 100, 500, 1000, 2000, 5000, 10000, 20000, 50000,
                                 100000, 200000, 500000, 1000000],
                           labels=False)

dfg = df.groupby(['length_bin']).mean()
dfg = dfg.loc[:, 'ig_f1': 'genic_f1']
# df = df['ig_f1', 'utr_f1', 'intron_f1', 'exon_f1', 'genic_f1']

dfgc = df.groupby(['length_bin']).count()

import pdb; pdb.set_trace()
pass



