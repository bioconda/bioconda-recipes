#! /usr/bin/env python3
"""Does very simple evaluation of a prediction file. Makes sure that the maximum memory footprint
always stays the same no matter the length of the sequences."""

import h5py
import argparse
import numpy as np
import sys
from helixer.prediction.Metrics import ConfusionMatrixGenic, ConfusionMatrix


def phase_from_dataset_name(ds_name):
    """get name of phase dataset that would usually correspond to name of y (or predictions) dataset"""
    if ds_name == 'predictions':
        return 'predictions_phase'
    elif ds_name.endswith('/y'):
        out = ds_name[:-1]  # drop just the y
        out += 'phases'
        return out
    else:
        raise ValueError("unknown relation between provided y-dataset {} and implied phase"
                         "dataset".format(ds_name))


def main(h5_file, preds_file=None, predictions_dataset='predictions', ground_truth_dataset='data/y'):
    h5_data = h5py.File(h5_file, 'r')
    if preds_file is not None:
        h5_pred = h5py.File(preds_file, 'r')
    else:
        h5_pred = h5_data

    y_true = h5_data[ground_truth_dataset]
    y_pred = h5_pred[predictions_dataset]

    phase_true = h5_data[phase_from_dataset_name(ground_truth_dataset)]
    phase_pred = h5_pred[phase_from_dataset_name(predictions_dataset)]

    sw = h5_data['/data/sample_weights']

    assert y_true.shape == y_pred.shape
    assert y_pred.shape[:-1] == sw.shape == phase_pred.shape[:-1] == phase_true.shape[:-1]

    # keep memory footprint the same no matter the seq length
    # batch_size should be 100 for 20k length seqs
    batch_size = 2 * 10 ** 6 // y_true.shape[1]
    print(f'Using batch size {batch_size}', file=sys.stderr)

    n_seqs = int(np.ceil(y_true.shape[0] / batch_size))
    cm = ConfusionMatrixGenic()
    cm_phase = ConfusionMatrix(col_names=['no_phase', 'phase_0', 'phase_1', 'phase_2'])
    cm_cds_phase = ConfusionMatrix(col_names=['phase_0', 'phase_1', 'phase_2'])
    # finally predicted not-CDS ("ref") vs predicted non-coding phase ("pred")
    sanity_cm = ConfusionMatrix(col_names=['not-coding', 'coding'])
    for i in range(n_seqs):
        print(i, '/', n_seqs, end='\r', file=sys.stderr)
        start = i * batch_size
        end = (i + 1) * batch_size
        # avoid double reads
        sw_mask = sw[start:end]
        sub_y_true = y_true[start:end]
        sub_y_pred = y_pred[start:end]
        sub_phase_true = phase_true[start:end]
        sub_phase_pred = phase_pred[start:end]

        # add to cm
        cm.count_and_calculate_one_batch(sub_y_true,
                                         sub_y_pred,
                                         sw_mask)

        cm_phase.count_and_calculate_one_batch(sub_phase_true, sub_phase_pred, sw_mask)
        # finally, cm_cds_phase is calculated only for regions marked as cds in the reference
        sw_cds_mask = np.logical_and(sw_mask, sub_y_true[:, :, 2])
        sw_cds_mask = np.logical_and(sw_cds_mask, (np.argmax(sub_y_pred, axis=-1) == 2))
        cm_cds_phase.count_and_calculate_one_batch(sub_phase_true[:, :, 1:],
                                                   sub_phase_pred[:, :, 1:],
                                                   sw_cds_mask)

    cm._get_scores()
    cm_phase._get_scores()
    cm_cds_phase._get_scores()

    print('\n\ngenic CM\n=========================')
    cm.print_cm()
    print('\n\nphase CM\n=========================')
    cm_phase.print_cm()
    print('\n\nphase CM (within intersect reference & predicted CDS)\n=========================')
    cm_cds_phase.print_cm()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--h5-data', help='h5 data file (with data/{X, y, species, seqids, etc ...}'
                                                'and evaluation/{coverage, spliced_coverage}, as output by'
                                                'the rnaseq.py script)', required=True)
    parser.add_argument('-p', '--h5-predictions', help='set if the predictions data set is in a separate '
                                                       '(but sort matching!) h5 file')
    parser.add_argument('--ground-truth-dataset', default='data/y',
                        help='ground truth dataset key in h5, also implicitly sets the phase')
    parser.add_argument('--predictions-dataset', default='predictions',
                        help='predictions dataset key in h5, also implicitly sets the phase')
    args = parser.parse_args()
    main(args.h5_data, args.h5_predictions, args.predictions_dataset, args.ground_truth_dataset)
