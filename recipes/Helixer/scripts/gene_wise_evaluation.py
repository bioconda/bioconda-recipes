#! /usr/bin/env python3
"""Evaluates prediction performance for individual genes of a species and also looks for
information like [start,end] or the number of alternative transcripts, so that the performance
can be evaluated in the light of gene length, etc

For this it first queries the database to get the gene extends and then runs those parts through
the ConfusionMatrix class. Here, the full extend of the gene is used while we use the longest
(by largest cds sum) transcript during data generation. It was probably not a smart idea to do it
this way and could easily be fixed by adjusting the queries used here (but may also not be the best).

For comparisons against AUGUSTUS, --augustus has to be used in order to match up the predictions.
"""

import os
import h5py
import sqlite3
import numpy as np
import argparse
import matplotlib.pyplot as plt
from collections import defaultdict
from intervaltree import IntervalTree
from terminaltables import AsciiTable
from helixer.prediction.ConfusionMatrix import ConfusionMatrix

parser = argparse.ArgumentParser()
parser.add_argument('-d', '--data', type=str, required=True,
                    help='This HAS to be from only one genome')
parser.add_argument('-p', '--predictions', type=str, required=True,
                    help='This HAS to be from only one genome')
parser.add_argument('-db', '--db-path', type=str, required=True)
parser.add_argument('-g', '--genome', type=str, required=True)
parser.add_argument('-o', '--output-file', type=str, default='alternative_splicing_results.csv')
parser.add_argument('--augustus', action='store_true', help=('If the prediction file has Augustus data.'
                    'Assumes Augustus predictions were numerified with --keep-errors.'))
args = parser.parse_args()

h5_data = h5py.File(args.data, 'r')
h5_pred = h5py.File(args.predictions, 'r')

y_true = h5_data['/data/y']
if args.augustus:
    y_pred = h5_pred['/data/y']
    seqids_aug = np.array(h5_pred['/data/seqids'])
    start_ends_aug = np.array(h5_pred['/data/start_ends'])
else:
    y_pred = h5_pred['/predictions']
sw = h5_data['/data/sample_weights']
seqids = np.array(h5_data['/data/seqids'])
start_ends = np.array(h5_data['/data/start_ends'])

gene_borders = dict()
with sqlite3.connect(args.db_path) as con:
    cur = con.cursor()
    # query all gene intervals with their relevant information
    # each strand is queried seperately
    joins = ('''CROSS JOIN coordinate ON coordinate.genome_id = genome.id
                CROSS JOIN feature ON feature.coordinate_id = coordinate.id
                CROSS JOIN association_transcript_piece_to_feature
                    ON association_transcript_piece_to_feature.feature_id = feature.id
                CROSS JOIN transcript_piece
                    ON association_transcript_piece_to_feature.transcript_piece_id = transcript_piece.id
                CROSS JOIN transcript ON transcript_piece.transcript_id = transcript.id
                CROSS JOIN super_locus ON transcript.super_locus_id = super_locus.id''')

    query_plus = ('''SELECT coordinate.seqid, super_locus.given_name,
                            min(feature.start), max(feature.end), count(distinct(transcript.id))
                   FROM genome ''' + joins + '''
                   WHERE genome.species IN ("''' + args.genome + '''") AND super_locus.type = 'gene'
                       AND transcript.type = 'mRNA' AND feature.type = 'geenuff_transcript'
                       AND feature.is_plus_strand = 1
                   GROUP BY super_locus.id
                   ORDER BY coordinate.seqid;''')
    query_minus = ('''SELECT coordinate.seqid, super_locus.given_name,
                             min(feature.end) + 1, max(feature.start) + 1, count(distinct(transcript.id))
                   FROM genome ''' + joins + '''
                   WHERE genome.species IN ("''' + args.genome + '''") AND super_locus.type = 'gene'
                       AND transcript.type = 'mRNA' AND feature.type = 'geenuff_transcript'
                       AND feature.is_plus_strand = 0
                   GROUP BY super_locus.id
                   ORDER BY coordinate.seqid;''')

    cur.execute(query_plus)
    gene_borders['plus'] = cur.fetchall()
    cur.execute(query_minus)
    gene_borders['minus'] = cur.fetchall()

is_on_strand = dict()
is_on_strand['plus'] = start_ends[:, 0] < start_ends[:, 1]
is_on_strand['minus'] = start_ends[:, 0] >= start_ends[:, 1]
if args.augustus:
    is_on_strand_aug = dict()
    is_on_strand_aug['plus'] = start_ends_aug[:, 0] < start_ends_aug[:, 1]
    is_on_strand_aug['minus'] = start_ends_aug[:, 0] >= start_ends_aug[:, 1]


last_seqid = ''
with open(f'{args.output_file}', 'w') as f:
    for strand in ['plus', 'minus']:
        for (seqid, sl_name, start, end, n_transcripts) in gene_borders[strand]:
            # get seqid array
            if seqid != last_seqid:
                print(f'Starting with seqid {seqid} on {strand} strand')
                seqid_idxs = np.where((seqids == str.encode(seqid)) & is_on_strand[strand])
                seqid_idxs = sorted(list(seqid_idxs[0]))
                if args.augustus:
                    seqid_idxs_aug = np.where((seqids_aug == str.encode(seqid))
                                               & is_on_strand_aug[strand])
                    seqid_idxs_aug = sorted(list(seqid_idxs_aug[0]))
                if seqid_idxs:
                    # select sequences of seqid + strand
                    y_true_seqid_seqs = y_true[seqid_idxs]
                    sw_seqid_seqs = sw[seqid_idxs]
                    if args.augustus:
                        y_pred_seqid_seqs = y_pred[seqid_idxs_aug]
                    else:
                        y_pred_seqid_seqs = y_pred[seqid_idxs]
                    # remove 0 padding
                    non_zero_bases = [np.any(arr, axis=-1) for arr in y_true_seqid_seqs]
                    y_true_seqid_seqs_nonzero = [y_true_seqid_seqs[i][non_zero_bases[i]]
                                                 for i in range(len(non_zero_bases))]
                    sw_seqid_seqs_nonzero = [sw_seqid_seqs[i][non_zero_bases[i]]
                                                 for i in range(len(non_zero_bases))]
                    if args.augustus:
                        non_zero_bases = [np.any(arr, axis=-1) for arr in y_pred_seqid_seqs]
                    y_pred_seqid_seqs_nonzero = [y_pred_seqid_seqs[i][non_zero_bases[i]]
                                                 for i in range(len(non_zero_bases))]
                    # add dummy data where fully erroneous sequences where removed
                    inserted_before = 0
                    for i in range(len(seqid_idxs) - 1):
                        end_before = start_ends[seqid_idxs][i][1]
                        start_after = start_ends[seqid_idxs][i + 1][0]
                        if end_before != start_after:
                            dummy_seq_dim_4 = np.zeros((abs(end_before - start_after), 4), dtype=np.int8)
                            y_true_seqid_seqs_nonzero.insert(i + inserted_before + 1, dummy_seq_dim_4)
                            if not args.augustus:
                                y_pred_seqid_seqs_nonzero.insert(i + inserted_before + 1,
                                                                 dummy_seq_dim_4)
                            dummy_seq_dim_1 = np.zeros((abs(end_before - start_after),), dtype=np.int8)
                            sw_seqid_seqs_nonzero.insert(i + inserted_before + 1, dummy_seq_dim_1)
                            inserted_before += 1
                    # concat
                    y_true_seqid = np.concatenate(y_true_seqid_seqs_nonzero)
                    y_pred_seqid = np.concatenate(y_pred_seqid_seqs_nonzero)
                    sw_seqid = np.concatenate(sw_seqid_seqs_nonzero)
                    # this assert fails when the were fully erroneous sequences at the very end
                    # they should not contain genes or if we have to add proper padding + sw
                    # assert y_true_seqid.shape[0] == y_pred_seqid.shape[0] == sw_seqid.shape[0]
                    if strand == 'minus':
                        # flip to align indices for minus strand
                        y_true_seqid = np.flip(y_true_seqid, axis=0)
                        y_pred_seqid = np.flip(y_pred_seqid, axis=0)
                        sw_seqid = np.flip(sw_seqid, axis=0)

            last_seqid = seqid
            if seqid_idxs:
                # cut out gene
                y_true_section = y_true_seqid[start:end]
                y_pred_section = y_pred_seqid[start:end]
                sw_section = sw_seqid[start:end]
                if np.any(sw_section):
                    # run through cm to get the genic f1
                    cm = ConfusionMatrix(None)
                    cm._add_to_cm(y_true_section, y_pred_section, sw_section)
                    scores = cm._get_composite_scores()
                    # writout results
                    print(','.join([seqid, strand, str(start), str(end), sl_name, str(n_transcripts),
                                    str(scores['ig']['f1']),
                                    str(scores['utr']['f1']),
                                    str(scores['intron']['f1']),
                                    str(scores['exon']['f1']),
                                    str(scores['sub_genic']['f1']),
                                    str(scores['genic']['f1'])]), file=f)
