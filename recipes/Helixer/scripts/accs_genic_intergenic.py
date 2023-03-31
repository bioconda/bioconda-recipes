#! /usr/bin/env python3
import h5py
import numpy as np
import argparse
from helixer.prediction.Metrics import ConfusionMatrixGenic, ConfusionMatrixPhase
import re
import os


class CMHolder:
    """manages a Conf. Mat. for class and for phase, w/ given filter function"""
    def __init__(self, mask_fn, name):
        self.mask_fn = mask_fn
        self.name = name
        self.cm_calc = ConfusionMatrixGenic(None)
        self.cm_phase = ConfusionMatrixPhase()

    def count_and_calculate_one_batch(self, sample_weights, data_y, pred_y,
                                      data_phase, pred_phase, transitions):

        mask = np.logical_and(self.mask_fn(transitions),
                              sample_weights)

        self.cm_calc.count_and_calculate_one_batch(data_y, pred_y, mask)
        if pred_phase is not None:
            self.cm_phase.count_and_calculate_one_batch(data_phase, pred_phase, mask)

    def print_cms(self):
        print(f'\n======= tables for: {self.name} =========')
        self.cm_calc.print_cm()
        self.cm_phase.print_cm()

    def export_to_csvs(self, stats_dir):
        self.cm_calc.export_to_csvs(os.path.join(stats_dir, self.name, 'genic_class'))
        self.cm_phase.export_to_csvs(os.path.join(stats_dir, self.name, 'phase'))


class H5Holder:
    def __init__(self, h5_data, h5_pred, h5_prediction_dataset):
        # find phase dataset based on prediction dataset
        if h5_prediction_dataset in ['predictions', '/predictions']:
            h5_phase_dataset = "predictions_phase"
        elif h5_prediction_dataset.endswith('/y'):
            h5_phase_dataset = re.sub('/y$', '/phases', args.h5_prediction_dataset)
        else:
            raise ValueError(f"do not know how to find phase dataset from {args.h5_prediction_dataset}")

        # get comparable subset of data
        # category
        self.data_y = h5_data['data/y']
        self.pred_y = h5_pred[h5_prediction_dataset]
        # phase
        self.data_phase = h5_data['data/phases']
        try:
            self.pred_phase = h5_pred[h5_phase_dataset]
        except KeyError:
            self.pred_phase = None
        # sample weights (to mask both of the above)
        self.sample_weights = h5_data['data/sample_weights']
        # transitions
        self.transitions = h5_data['data/transitions']

    @property
    def datasets(self):
        # sorting here MUST MATCH that in CMHolder count_and_calculate_one_batch args
        # but it's very io inefficient to get these there
        return [self.sample_weights,
                self.data_y,
                self.pred_y,
                self.data_phase,
                self.pred_phase,
                self.transitions]

def no_mask(transitions):
    return np.ones(shape=transitions.shape[:2], dtype=bool)


def any_transition(transitions):
    return np.sum(transitions, axis=-1).astype(bool)


def transcript_transition(transitions):
    return np.sum(transitions[:, : , [0, 3]], axis=-1).astype(bool)


def coding_transition(transitions):
    return np.sum(transitions[:, :, [1, 4]], axis=-1).astype(bool)


def intron_transition(transitions):
    return np.sum(transitions[:, :, [2, 5]], axis=-1).astype(bool)

def slice_or_none(dataset, i, size):
    if dataset is not None:
        return dataset[i:(i + size)]
    else:
        return None


def main(args):

    h5_data = h5py.File(args.data, 'r')
    h5_pred = h5py.File(args.predictions, 'r')

    h5h = H5Holder(h5_data, h5_pred, args.h5_prediction_dataset)

    # prepare
    cm_holders = [CMHolder(no_mask, "all"),
                  CMHolder(any_transition, "transition"),
                  CMHolder(transcript_transition, "transcript_transition"),
                  CMHolder(coding_transition, "coding_transition"),
                  CMHolder(intron_transition, "intron_transition")
                  ]

    # sanity check
    assert h5h.data_y.shape == h5h.pred_y.shape

    # truncate (for devel efficiency, when we don't need the whole answer)
    if args.truncate is not None:
        end = args.truncate
    else:
        end = h5h.data_y.shape[0]

    # random subset (for devel efficiency, or just if we don't care that much about the full accuracy
    if args.sample is not None:
        a_sample = np.random.choice(
            np.arange(end),
            size=[args.sample],
            replace=False
        )
        a_sample = np.sort(a_sample)
        for key, val in h5h.__dict__.items():
            h5h.__setattr__(key, val[a_sample])

    # break into chunks (keep mem usage minimal)
    i = 0
    size = 100
    while i < end:
        # sorting here MUST MATCH that in CMHolder function args
        batches = [slice_or_none(ds, i, size) for ds in h5h.datasets]

        for cmh in cm_holders:
            cmh.count_and_calculate_one_batch(*batches)

        i += size

    # report output
    for cmh in cm_holders:
        cmh.print_cms()
        cmh.export_to_csvs(args.stats_dir)



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', type=str, required=True)
    parser.add_argument('--predictions', type=str, required=True,
                        help="predictions h5 file, sorting _must_ match that of --data!")
    parser.add_argument('--stats_dir', type=str, required=True,
                        help="export several csv files of the calculated stats in this (nested) directory")
    parser.add_argument('--truncate', type=int, default=None, help="look at just the first N chunks of each sequence")
    parser.add_argument('--h5_prediction_dataset', type=str, default='/predictions',
                        help="dataset in predictions h5 file to compare with data's '/data/y', default='/predictions',"
                             "the other likely option is '/data/y' or alternative/<something>/y")
    parser.add_argument('--sample', type=int, default=None,
                        help="take a random sample of the data of this many chunks per sequence")
    args = parser.parse_args()
    main(args)
