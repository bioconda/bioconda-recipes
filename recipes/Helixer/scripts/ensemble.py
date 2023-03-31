#! /usr/bin/env python3
"""Generates an ensemble from 2 or more prediction files. All files must have the same shape.
The ensembling is done by averaging the individual softmax values."""

import h5py
import datetime
import argparse
import numpy as np
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-p', '--prediction-files', nargs='+', required=True)
parser.add_argument('-po', '--prediction-output-path', type=str, default='ensembled_predictions.h5')
args = parser.parse_args()

# make sure we have at least 2 predictions
assert args.prediction_files and len(args.prediction_files) > 1

h5_pred_files, y_preds, phase_preds = [], [], []
for pf in args.prediction_files:
    f = h5py.File(pf, 'r')
    y_preds.append(f['/predictions'])
    if 'predictions_phase' in f.keys():
        phase_preds.append(f['/predictions_phase'])
    h5_pred_files.append(f)

# warn if predictions are not all for the same test data
test_data_files = [f.attrs['test_data_path'] for f in h5_pred_files]
if len(set(test_data_files)) > 1:
    print(f'WARNING: Not all test data file paths of the predictions files are equal: {test_data_files}')

for datasets in [y_preds, phase_preds]:
    shapes = [dset.shape for dset in datasets]
    if shapes:
        assert len(set(shapes)) == 1, f'Prediction shapes are not equal: {shapes}'



# create output dataset
n_seqs = shapes[0][0]
h5_ensembled = h5py.File(args.prediction_output_path, 'w')


def mk_ensembled_dset(h5_ensembled, key, dset):
    h5_ensembled.create_dataset(key,
                                shape=(dset.shape[0],) + dset.shape[1:],
                                chunks=(1,) + dset.shape[1:],
                                dtype='float16',
                                compression='lzf',
                                shuffle=True)


mk_ensembled_dset(h5_ensembled, '/predictions', y_preds[0])
mk_ensembled_dset(h5_ensembled, '/predictions_phase', phase_preds[0])


# ensemble and add predictions
def mean_ensemble(datasets):
    seq_predictions = np.stack([dset[i] for dset in datasets], axis=0)
    seq_predictions = np.mean(seq_predictions, axis=0)
    return seq_predictions


for i in range(n_seqs):
    print(i, '/', n_seqs - 1, end='\r')
    # save data one sequence at a time to save memory at the expense of speed
    h5_ensembled['/predictions'][i] = mean_ensemble(y_preds)
    if phase_preds:
        h5_ensembled['/predictions_phase'][i] = mean_ensemble(phase_preds)

# also save some model attrs
h5_ensembled.attrs['timestamp'] = str(datetime.datetime.now())
h5_ensembled.attrs['model_md5sum'] = ','.join([dset.attrs['model_md5sum'] for dset in h5_pred_files])
h5_ensembled.attrs['model_path'] = ','.join([dset.attrs['model_path'] for dset in h5_pred_files])
h5_ensembled.attrs['test_data_path'] = ','.join([dset.attrs['test_data_path'] for dset in h5_pred_files])

h5_ensembled.close()
