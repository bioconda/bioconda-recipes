#! /usr/bin/env python3
"""Benchmarks different compression algorithms for in-memory compression of data"""

import sys
import time
import h5py
import random
import numpy as np
import argparse
import numcodecs
from sklearn.utils import shuffle

def generate_batch(args, data, offset, dtypes, compressor):
    batch = []
    for i, data_list in enumerate(data):
        decoded_list = [np.frombuffer(compressor.decode(e), dtype=dtypes[i])
                        for e in data_list[offset:offset+args.batch_size]]
        if len(decoded_list[0]) > 20000:
            decoded_list = [e.reshape(20000, -1) for e in decoded_list]
        batch.append(np.stack(decoded_list, axis=0))
    return batch


parser = argparse.ArgumentParser()
parser.add_argument('--data', type=str, required=True)
parser.add_argument('--datasets', type=str, nargs='+',
                    default=['X', 'y', 'sample_weights', 'transitions'])
parser.add_argument('--cname', type=str, default='blosclz')
parser.add_argument('--clevel', type=int, default=4)
parser.add_argument('--shuffle', type=int, default=1, choices=[0, 1, 2])
parser.add_argument('--blocksize', type=int, default=0, help='Could be L2 cache size')
parser.add_argument('--n-threads', type=int, default=8)
parser.add_argument('--batch_size', type=int, default=70)
parser.add_argument('--iterations', type=int, default=100)
args = parser.parse_args()

h5_file = h5py.File(args.data, 'r')
compressor = numcodecs.blosc.Blosc(cname=args.cname, clevel=args.clevel, shuffle=args.shuffle,
                                   blocksize=args.blocksize)
numcodecs.blosc.set_nthreads(args.n_threads)
print(compressor)

data = []
dtypes = [h5_file[f'data/{dset}'].dtype for dset in args.datasets]
print(dtypes, end='\n\n')
for dset in args.datasets:
    print(f'{dset}: starting to load data in memory')
    start_time = time.time()
    raw_data = h5_file[f'data/{dset}'][:]
    load_end_time = time.time()
    print(f'{dset}: data loading in memory took {load_end_time - start_time:.2f} sec')
    print(f'{dset}: data shape: {raw_data.shape}')
    data.append([compressor.encode(raw_data[i]) for i in range(raw_data.shape[0])])
    print(f'{dset}: data compression in memory took {time.time() - load_end_time:.2f} sec')

    raw_data_size = raw_data.nbytes / 2 ** 30
    comp_data_size = sum([sys.getsizeof(e) for e in data[-1]]) / 2 ** 30
    print(f'{dset}: data sizes: {raw_data_size:.6f} GB vs. {comp_data_size:.6f} GB')
    print(f'{dset}: compression ratio: {raw_data_size / comp_data_size:.4f}\n')

data = shuffle(*data)

times = []
for i in range(args.iterations):
    start_time = time.time()
    generate_batch(args, data, i * args.batch_size, dtypes, compressor)
    times.append(time.time() - start_time)
print(f'data decompression of one batch in memory took {np.mean(times):.6f} sec')

