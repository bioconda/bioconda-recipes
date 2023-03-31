#! /usr/bin/env python3

"""Prints overall statistics like genome size, error rate and fragmentation for each
genome in a subfolder of a given folder as well as the overall statistics for all
genomes combined."""

import os
import h5py
import numpy as np
import argparse
from collections import defaultdict

def listdir_fullpath(d):
    return [os.path.join(d, f) for f in os.listdir(d)]

parser = argparse.ArgumentParser()
parser.add_argument('main_folder', type=str)
parser.add_argument('--max-bases', type=int, default=400000)

args = parser.parse_args()

results = defaultdict(dict)
print(','.join(['species', 'total_len', 'total_padding', 'error_rate', 'intergenic_error_rate', 'ig_rate',
                'utr_rate', 'cds_rate', 'intron_rate']))
for folder in listdir_fullpath(args.main_folder)[::-1]:
    species = os.path.basename(folder)
    f = h5py.File(os.path.join(folder, 'test_data.h5'), 'r')
    sw = f['/data/sample_weights']
    y = f['/data/y']

    # read in the data in chunks for memory reasons
    chunk_size = args.max_bases // y.shape[1]
    offsets = range(0, y.shape[0], chunk_size)
    species_r = results[species]
    species_r['total_errors'], species_r['total_padding'] = 0, 0
    species_r['total_intergenic_error'] = 0
    species_r['total_classes'] = np.zeros((4,), dtype=np.uint64)
    species_r['total_len'] = sw.size

    for offset in offsets:
        y_chunk = y[offset:offset + chunk_size].reshape((-1, 4))
        sw_chunk = sw[offset:offset + chunk_size].ravel()
        species_r['total_classes'] = np.add(species_r['total_classes'],
                                            np.count_nonzero(y_chunk, axis=0))
        species_r['total_errors'] += np.count_nonzero(sw_chunk == 0)

        intergenic_errors = np.logical_and(y_chunk[:, 0] == 1, sw_chunk == 0)
        species_r['total_intergenic_error'] += np.count_nonzero(intergenic_errors)
        species_r['total_padding'] += np.count_nonzero(np.all(y_chunk == 0, axis=-1))


    # remove padding
    species_r['total_bases'] = species_r['total_len'] - species_r['total_padding']
    species_r['total_errors'] = species_r['total_errors'] - species_r['total_padding']

    species_r['error_rate'] = species_r['total_errors'] / species_r['total_bases']
    species_r['intergenic_error_rate'] = species_r['total_intergenic_error'] / species_r['total_errors']
    species_r['class_rates'] = species_r['total_classes'] / species_r['total_bases']
    assert np.sum(species_r['total_classes']) == species_r['total_bases']

    formatted_stats = [species, f'{species_r["total_bases"]}', f'{species_r["total_padding"]}',
            f'{species_r["error_rate"]:.4f}', f'{species_r["intergenic_error_rate"]:.4f}']
    formatted_stats += [f'{e:.4f}' for e in species_r['class_rates']]
    print(','.join(formatted_stats))
