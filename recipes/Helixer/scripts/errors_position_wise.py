#! /usr/bin/env python3
"""Evaluates predictions by position in the sequence. This was a major bias we found in the data and
that was softened with overlapping. This script outputs a plot of the position-wise bias accross all
sequences in a data/prediction file pair.

It also output the confusion matrix for each length subsection. This output is later used by
before_after_overlapping_comparisons.py to make the comparison plots. Also outputs a final overall
evaluation, which is the same as when run with basic_pred_cm.py.

The usefulness of the overlapping seems to be heavily dependent on the underlying FASTA
sequence length (which we also call seqid or coordinate). To investigate this, the script can be run
with --plot-every-chunk, which outputs multiple plots that each should represent shorten and shorter
FASTA sequences as we sort by that during numerification.

It is also possible to only consider the start of each FASTA sequence with --only-start-seqs.

The maximum memory footprint (and chunk size) can be controlled with --max-base-pairs."""

import os
import h5py
import numpy as np
import argparse
import matplotlib.pyplot as plt
from terminaltables import AsciiTable
from helixer.prediction.ConfusionMatrix import ConfusionMatrix

parser = argparse.ArgumentParser()
parser.add_argument('-d', '--data', type=str, required=True)
parser.add_argument('-p', '--predictions', type=str, required=True)
parser.add_argument('-s', '--sample', type=int, default=None)
parser.add_argument('-o', '--output-folder', type=str, default='')
parser.add_argument('-g', '--genome', type=str, default='')
parser.add_argument('-res', '--resolution', type=int, default=100,
                    help='How often to divide the sequences')
parser.add_argument('-maxbp', '--max-base-pairs', type=int, default=500000,
                    help='The total size loaded into memory at a time')
parser.add_argument('-os', '--only-start-seqs', action='store_true')
parser.add_argument('-pec', '--plot-every-chunk', action='store_true')
args = parser.parse_args()

h5_data = h5py.File(args.data, 'r')
h5_pred = h5py.File(args.predictions, 'r')
genome = args.genome if args.genome else args.data.strip().split('/')[6]

if args.sample:
    print('Sampling {} rows'.format(args.sample))
    a_sample = np.random.choice(h5_data['/data/y'].shape[0], size=[args.sample], replace=False)
    a_sample = list(np.sort(a_sample))
    y_true = h5_data['/data/y'][a_sample]
    y_pred = h5_pred['/predictions'][a_sample]
else:
    y_true = h5_data['/data/y']
    y_pred = h5_pred['/predictions']

assert y_true.shape == y_pred.shape
sw = h5_data['/data/sample_weights']
block_size = y_true.shape[1] // args.resolution
# automatically determined chunk size that ensures constant memory usage no matter how long
# the sequences (2GB should be enough with these settings)
chunk_size = args.max_base_pairs // block_size

if args.only_start_seqs:
    seqids = np.array(h5_data['/data/seqids'])
    idx_border = np.squeeze(np.argwhere(seqids[:-1] != seqids[1:]))
    idx_border = list(np.add(idx_border, 1))
    y_true, y_pred, sw = y_true[idx_border], y_pred[idx_border], sw[idx_border].astype(np.bool)

total_accs, genic_f1s = [], []
chunk_offsets = list(range(0, y_true.shape[0], chunk_size))
length_offsets = list(range(0, y_true.shape[1], block_size))
correct_bases = np.zeros((len(chunk_offsets), len(length_offsets)))
total_bases = np.zeros((len(chunk_offsets), len(length_offsets)))
cm_total = ConfusionMatrix(None)
cms = [ConfusionMatrix(None) for _ in range(len(length_offsets))]
for i, co in enumerate(chunk_offsets):
    y_true_block = y_true[co:co+chunk_size]
    y_pred_block = y_pred[co:co+chunk_size]
    y_diff_block = np.argmax(y_true_block, axis=-1) == np.argmax(y_pred_block, axis=-1)

    if args.plot_every_chunk:
        cms_chunk = [ConfusionMatrix(None) for _ in range(len(length_offsets))]
    lo_accs = []
    for j, lo in enumerate(length_offsets):
        print(f'chunk: {i + 1} / {len(chunk_offsets)}',
              f', length: {j + 1} / {len(length_offsets)}  ',
              end='\r')
        y_true_block_section = y_true_block[:, lo:lo+block_size].reshape((-1, 4))
        y_pred_block_section = y_pred_block[:, lo:lo+block_size].reshape((-1, 4))
        y_diff_block_section = y_diff_block[:, lo:lo+block_size].ravel()

        # apply sw
        sw_block_section = sw[co:co+chunk_size, lo:lo+block_size].ravel().astype(np.bool)
        if np.any(sw_block_section):
            y_diff_block_section = y_diff_block_section[sw_block_section]

            correct_bases[i, j] = np.count_nonzero(y_diff_block_section)
            total_bases[i, j] = len(y_diff_block_section)

            cms[j]._add_to_cm(y_true_block_section, y_pred_block_section, sw_block_section)
            cm_total._add_to_cm(y_true_block_section, y_pred_block_section, sw_block_section)
            if args.plot_every_chunk:
                cms_chunk[j]._add_to_cm(y_true_block_section, y_pred_block_section, sw_block_section)
        else:
            print('No non-erroneous base found in this chunk/length block')
    if args.plot_every_chunk:
        chunk_genic_f1s = [cm._get_composite_scores()['genic']['f1'] for cm in cms_chunk]
        plt.plot(length_offsets, chunk_genic_f1s, label=f'genic f1 {co}')
        plt.ylim((0.0, 1.0))
        plt.xlabel('length offset')
        plt.legend()
        plt.savefig(os.path.join(args.output_folder, f'{genome}_chunks.png'))

for cm in cms:
    cm.print_cm()

# print accuracies
table = [['index', 'overall acc']]
accs_offset = np.divide(np.sum(correct_bases, axis=0), np.sum(total_bases, axis=0))
for i, offset in enumerate(length_offsets):
    table.append(f'{offset}\t{accs_offset[i]:.4f}'.split('\t'))
print('\n', AsciiTable(table).table, sep='')

# print total cm
genic_f1s = [cm._get_composite_scores()['genic']['f1'] for cm in cms]
cm_total.print_cm()

# output overall plot
plt.cla()
plt.title(genome)
plt.plot(length_offsets, accs_offset, label='overall acc')
plt.plot(length_offsets, genic_f1s, label='genic f1')
plt.ylim((0.0, 1.0))
plt.xlabel('length offset')
plt.legend()
picture_name = genome + '_length_wise.png'
plt.savefig(os.path.join(args.output_folder, picture_name))
print(picture_name, 'saved')
