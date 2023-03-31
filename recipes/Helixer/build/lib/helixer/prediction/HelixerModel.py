from abc import ABC, abstractmethod
import os
import sys

import helixer.core.helpers

try:
    import nni
except ImportError:
    pass
import time
import glob
import h5py
import numcodecs
import argparse
import datetime
import pkg_resources
import subprocess
import numpy as np
import tensorflow as tf
from sklearn.utils import shuffle
from pprint import pprint
from termcolor import colored
from terminaltables import AsciiTable

from tensorflow.keras.callbacks import Callback
from tensorflow.keras import optimizers
from tensorflow.keras import backend as K
from tensorflow.keras.models import load_model
from tensorflow.keras.utils import Sequence
from tensorflow_addons.optimizers import AdamW

from helixer.prediction.Metrics import Metrics
from helixer.core import overlap


class ConfusionMatrixTrain(Callback):
    def __init__(self, save_model_path, train_generator, val_generator, large_eval_folder, patience, calc_H=False,
                 report_to_nni=False, check_every_nth_batch=1_000_000, save_every_check=False):
        self.save_model_path = save_model_path
        self.save_dir = os.path.dirname(save_model_path)
        self.save_every_check = save_every_check
        self.train_generator = train_generator
        self.val_generator = val_generator
        self.large_eval_folder = large_eval_folder
        self.patience = patience
        self.calc_H = calc_H
        self.report_to_nni = report_to_nni
        self.best_val_genic_f1 = 0.0
        self.checks_without_improvement = 0
        self.check_every_nth_batch = check_every_nth_batch  # high default for ~ 1 / epoch
        self.epoch = 0
        print(self.save_model_path, 'SAVE MODEL PATH')

    def on_epoch_begin(self, epoch, logs=None):
        self.epoch_start = time.time()

    def on_epoch_end(self, epoch, logs=None):
        print(f'training took {(time.time() - self.epoch_start) / 60:.2f}m')
        self.check_in()
        self.epoch += 1

    def on_train_batch_end(self, batch, logs=None):
        if not (batch + 1) % self.check_every_nth_batch:
            print(f'\nvalidation and checkpoint at batch {batch}')
            self.check_in(batch)

    def check_in(self, batch=None):
        _, _, val_genic_f1 = HelixerModel.run_metrics(self.val_generator, self.model, calc_H=self.calc_H)
        if self.report_to_nni:
            nni.report_intermediate_result(val_genic_f1)
        if val_genic_f1 > self.best_val_genic_f1:
            self.best_val_genic_f1 = val_genic_f1
            self.model.save(self.save_model_path, save_format='h5')
            print('saved new best model with genic f1 of {} at {}'.format(self.best_val_genic_f1,
                                                                          self.save_model_path))
            self.checks_without_improvement = 0
        else:
            self.checks_without_improvement += 1
            if self.checks_without_improvement >= self.patience:
                self.model.stop_training = True
        if batch is None:
            b_str = 'epoch_end'
        else:
            b_str = f'b{batch:06}'
        if self.save_every_check:
            path = os.path.join(self.save_dir, f'model_e{self.epoch}_{b_str}.h5')
            self.model.save(path, save_format='h5')
            print(f'saved model at {path}')

    def on_train_end(self, logs=None):
        if os.path.isdir(self.large_eval_folder):
            # load best model
            best_model = load_model(self.save_model_path)
            # double check that we loaded the correct model, can be remove if confirmed this works
            print('\nValidation set again:')
            _, _, val_genic_f1 = HelixerModel.run_metrics(self.val_generator, best_model, print_to_stdout=True,
                                                          calc_H=self.calc_H)
            assert val_genic_f1 == self.best_val_genic_f1

            training_species = self.train_generator.h5_file.attrs['genomes']
            median_f1 = HelixerModel.run_large_eval(self.large_eval_folder, best_model, self.val_generator, training_species)

            if self.report_to_nni:
                nni.report_final_result(median_f1)

        elif self.report_to_nni:
            nni.report_final_result(self.best_val_genic_f1)


class PreshuffleCallback(Callback):
    def __init__(self, train_generator):
        self.train_generator = train_generator

    def on_epoch_begin(self, epoch, logs=None):
        if self.train_generator.shuffle:
            self.train_generator.shuffle_data()


class HelixerSequence(Sequence):
    def __init__(self, model, h5_files, mode, batch_size, shuffle):
        assert mode in ['train', 'val', 'test']
        self.model = model
        self.h5_files = h5_files
        self.mode = mode
        self.shuffle = shuffle
        self.batch_size = batch_size
        self._cp_into_namespace(['float_precision', 'class_weights', 'transition_weights', 'input_coverage',
                                 'coverage_norm', 'overlap', 'overlap_offset', 'core_length',
                                 'stretch_transition_weights', 'coverage_weights', 'coverage_offset',
                                 'no_utrs', 'predict_phase', 'load_predictions', 'only_predictions', 'debug'])

        if self.mode == 'test':
            assert len(self.h5_files) == 1, "predictions and eval should be applied to individual files only"

        # set chunk size and overlap parameters
        # this is first done here, because its pulled dynamically from h5 files
        chunk_sizes = [h5['data/X'].shape[1] for h5 in self.h5_files]
        for cs in chunk_sizes[1:]:
            assert cs == chunk_sizes[0], f'Not all subsequence lengths match in h5_files: {chunk_sizes}'
        self.chunk_size = chunk_sizes[0]
        # once we have the chunk_size, we can find defaults for overlapping
        if self.overlap_offset is None:
            self.overlap_offset = self.chunk_size // 2
        if self.core_length is None:
            self.core_length = int(self.chunk_size * 3 / 4)

        self.data_list_names = ['data/X']
        if not self.only_predictions:
            self.data_list_names += ['data/y', 'data/sample_weights']
            if self.load_predictions:
                self.data_list_names.append('data/predictions')
            if self.predict_phase:
                self.data_list_names.append('data/phases')
            if self.mode == 'train':
                if self.transition_weights is not None:
                    self.data_list_names.append('data/transitions')
                if self.coverage_weights:
                    self.data_list_names.append('scores/by_bp')

        if self.overlap:
            assert self.mode == "test", "overlapping currently only works for test (predictions & eval)"
            # can take [0] below bc we've asserted that test means len(self.h5_files) == 1 above
            contiguous_ranges = helixer.core.helpers.get_contiguous_ranges(self.h5_files[0])
            self.ol_helper = overlap.OverlapSeqHelper(contiguous_ranges=contiguous_ranges,
                                                      chunk_size=self.chunk_size,
                                                      max_batch_size=self.batch_size,
                                                      overlap_offset=self.overlap_offset,
                                                      core_length=self.core_length)

        if self.input_coverage and not self.only_predictions:
            self.data_list_names += ['evaluation/coverage', 'evaluation/spliced_coverage']

        self.data_lists = [[] for _ in range(len(self.data_list_names))]
        self.data_dtypes = [self.h5_files[0][name].dtype for name in self.data_list_names]

        self.compressor = numcodecs.blosc.Blosc(cname='blosclz', clevel=4, shuffle=2)  # use BITSHUFFLE

        print(f'\nstarting to load {self.mode} data into memory..')
        for h5_file in self.h5_files:
            self._load_one_h5(h5_file)

        for name, data_list in zip(self.data_list_names, self.data_lists):
            comp_data_size = sum([sys.getsizeof(e) for e in data_list])
            print(f'Compressed data size of {name} is at least {comp_data_size / 2 ** 30:.4f} GB\n')

        self.n_seqs = len(self.data_lists[0])
        print(f'setting self.n_seqs to {self.n_seqs}, bc that is len of {self.data_list_names[0]}')

        if self.mode == "test":
            if self.class_weights is not None:
                print(f'ignoring the class_weights of {self.class_weights} in mode "test"')
                self.class_weights = None
            if self.transition_weights is not None:
                print(f'ignoring the transition_weights of {self.transition_weights} in mode "test"')
                self.transition_weights = None


    def _load_one_h5(self, h5_file):
        print(f'For h5 starting with species = {h5_file["data/species"][0]}:')
        x_dset = h5_file['data/X']
        print(f'x shape: {x_dset.shape}')
        if not self.only_predictions:
            y_dset = h5_file['data/y']
            print(f'y shape: {y_dset.shape}')

        if self.debug:
            # so that total sequences between all files add to ~1000
            n_seqs = max(1000 // len(self.h5_files), 1)
        else:
            n_seqs = x_dset.shape[0]

        if self.mode == "train" or self.mode == 'val':
            mask = np.logical_and(h5_file['data/is_annotated'],
                                  h5_file['data/err_samples'])
            n_masked = x_dset.shape[0] - np.sum(mask)
            print(f'\nmasking {n_masked} completely un-annotated or completely erroneous sequences')
                
        else:
            mask = np.ones(h5_file['data/X'].shape[0], dtype=bool)
            n_masked = 0

        # load at most 2000 uncompressed samples at a time in memory
        max_at_once = min(2000, n_seqs)
        for name, data_list in zip(self.data_list_names, self.data_lists):
            start_time_dset = time.time()
            for offset in range(0, n_seqs, max_at_once):
                step_mask = mask[offset:offset + max_at_once]
                if name == 'data/predictions':
                    data_slice = h5_file[name][0, offset:offset + max_at_once][step_mask]  # only use one prediction for now
                else:
                    data_slice = h5_file[name][offset:offset + max_at_once][step_mask]
                if self.no_utrs and name == 'data/y':
                    HelixerSequence._zero_out_utrs(data_slice)
                data_list.extend([self.compressor.encode(e) for e in data_slice])
            print(f'Data loading of {n_seqs - n_masked} (total so far {len(data_list)}) samples of {name} '
                  f'into memory took {time.time() - start_time_dset:.2f} secs')

    @staticmethod
    def _zero_out_utrs(y):
        # merge UTR and IG labels and zero out the UTR column
        # still keep 4 columns for simplicity of downstream code and (maybe) more transfer learning potential
        y[..., 0] = np.logical_or(y[..., 0], y[..., 1])
        y[..., 1] = 0

    def shuffle_data(self):
        start_time = time.time()
        self.data_lists = shuffle(*self.data_lists)
        print(f'Reshuffled {self.mode} data in {time.time() - start_time:.2f} secs')

    def _cp_into_namespace(self, names):
        """Moves class properties from self.model into this class for brevity"""
        for name in names:
            self.__dict__[name] = self.model.__dict__[name]

    def _get_batch_data(self, batch_idx):
        batch = []
        # batch must have one thing for everything unpacked by __getitem__ (and in order)
        for name in ['data/X', 'data/y', 'data/sample_weights', 'data/transitions', 'data/phases',
                     'data/predictions', 'scores/by_bp']:
            if name not in self.data_list_names:
                batch.append(None)
            else:
                decoded_list = self.get_batch_of_one_dataset(name, batch_idx)

                # append coverage to X directly, might be clearer elsewhere once working, but this needs little code...
                if name == 'data/X' and self.input_coverage:
                    decode_coverage = self.get_batch_of_one_dataset('evaluation/coverage', batch_idx)
                    decode_coverage = [self._cov_norm(x.reshape(-1, 1)).astype(np.float16) for x in decode_coverage]
                    decode_spliced = self.get_batch_of_one_dataset('evaluation/spliced_coverage', batch_idx)
                    decode_spliced = [self._cov_norm(x.reshape(-1, 1)).astype(np.float16) for x in decode_spliced]
                    decoded_list = [np.concatenate((x, y, z), axis=1) for x, y, z in
                                    zip(decoded_list, decode_coverage, decode_spliced)]

                decoded = np.stack(decoded_list, axis=0)
                if self.overlap and name == 'data/X':
                    decoded = self.ol_helper.make_input(batch_idx, decoded)

                batch.append(decoded)

        return tuple(batch)

    def get_batch_of_one_dataset(self, name, batch_idx):
        """returns single batch (the Nth where N=batch_idx) from dataset '{name}'"""
        # setup indices based on overlapping or not
        if self.overlap:
            h5_indices = self.ol_helper.h5_indices_of_batch(batch_idx)
        else:
            end = min(self.n_seqs, (batch_idx + 1) * self.batch_size)
            h5_indices = np.arange(batch_idx * self.batch_size, end)

        return self._decode_one(name, h5_indices)

    def _decode_one(self, name, h5_indices):
        """decode batch delineated by h5_indices from compressed data originally from dataset {name}"""
        i = self.data_list_names.index(name)
        dtype = self.data_dtypes[i]
        data_list = self.data_lists[i]
        decoded_list = [np.frombuffer(self.compressor.decode(data_list[idx]), dtype=dtype)
                        for idx in h5_indices]
        if len(decoded_list[0]) > self.chunk_size:
            decoded_list = [e.reshape(self.chunk_size, -1) for e in decoded_list]
        return decoded_list

    def _cov_norm(self, x):
        method = self.coverage_norm
        if method is None:
            return x
        elif method == 'log':
            return np.log(x + 1.1)
        elif method == 'linear':
            return x / 100
        else:
            raise ValueError(f'unrecognized method: {method} for normalizing coverage data')

    def _update_sw_with_transition_weights(self):
        pass

    def _update_sw_with_coverage_weights(self):
        pass

    def _mk_timestep_pools(self, matrix):
        """reshape matrix to have multiple bp per timestep (in last dim)"""
        # assumes input shape
        # [0] = batch_size            --> don't touch
        # [1] = data's chunk_size     --> divide by pool size
        # [2:] = collapsable          --> -1, remaining, AKA np.prod(shape[2:]) * pool_size
        pool_size = self.model.pool_size
        if matrix is None:
            return None
        shape = list(matrix.shape)
        shape[1] = shape[1] // pool_size
        shape[-1] = -1
        matrix = matrix.reshape((
            shape
        ))
        return matrix

    def _mk_timestep_pools_class_last(self, matrix):
        """reshape matrix to have multiple bp per timestep, w/ classes as last dim for softmax"""
        if matrix is None:
            return None
        pool_size = self.model.pool_size
        assert len(matrix.shape) == 3
        # assumes input shape
        # [0] = batch_size            --> don't touch
        # [1] = data's chunk_size     --> divide by pool size
        # [2] = labels                --> pooling inserted before, retained as last dimension
        matrix = matrix.reshape((
            matrix.shape[0],
            matrix.shape[1] // pool_size,
            pool_size,  # make labels 2d so we can use the standard softmax / loss functions
            matrix.shape[-1],
        ))
        return matrix

    def _aggregate_timestep_pools(self, matrix, aggr_function=np.mean):
        pass

    def compress_tw(self, transitions):
        return self._squish_tw_to_sw(transitions, self.transition_weights, self.stretch_transition_weights)

    @staticmethod
    def _squish_tw_to_sw(transitions, transition_weights, stretch):
        # basically completes a max pool of transitions, from their pre-timestep pooled form
        max_pooled_trns = np.max(transitions, axis=2).astype(np.int8)

        # multiply by weights, and sum classes
        pooled_weighted_trns = np.multiply(max_pooled_trns, transition_weights)
        summed_trns = np.sum(pooled_weighted_trns, axis=2)

        # replace 0's (where weighting shouldn't change) with 1's as this will be multiplied later
        summed_trns[summed_trns == 0] = 1

        # maybe stretch transitions to upweight surrounding region somewhat (DEPRECATED bc performance was equivalent)
        if stretch != 0:
            summed_trns = HelixerSequence._apply_stretch(summed_trns, stretch)

        return summed_trns

    @staticmethod
    def _apply_stretch(reshaped_sw_t, stretch):
        """modifies sample weight shaped transitions so that they are a peak instead of a single point"""
        reshaped_sw_t = np.array(reshaped_sw_t)
        dilated_rf = np.ones(np.shape(reshaped_sw_t))

        where = np.where(reshaped_sw_t > 1)
        i = np.array(where[0])  # i unchanged
        j = np.array(where[1])  # j +/- step

        # find dividers depending on the size of the dilated rf
        dividers = []
        for distance in range(1, stretch + 1):
            dividers.append(2**distance)

        for z in range(stretch, 0, -1):
            dilated_rf[i, np.maximum(np.subtract(j, z), 0)] = np.maximum(reshaped_sw_t[i, j]/dividers[z-1], 1)
            dilated_rf[i, np.minimum(np.add(j, z), len(dilated_rf[0])-1)] = np.maximum(reshaped_sw_t[i, j]/dividers[z-1], 1)
        dilated_rf[i, j] = np.maximum(reshaped_sw_t[i, j], 1)
        return dilated_rf

    def __len__(self):
        """how many batches in epoch"""
        if self.debug:
            # if self.debug and self.mode == 'train':
            return 3
        elif self.overlap:
            return self.ol_helper.adjusted_epoch_length()
        else:
            return int(np.ceil(self.n_seqs / self.batch_size))

    @abstractmethod
    def __getitem__(self, idx):
        pass

    def _generic_get_item(self, idx):
        """covers the data preprocessing (reshape, trim, weighting, etc) common to all models"""
        X, y, sw, transitions, phases, _, coverage_scores = self._get_batch_data(idx)
        pool_size = self.model.pool_size

        if pool_size > 1:
            if X.shape[1] % pool_size != 0:
                # clip to maximum size possible with the pooling length
                overhang = X.shape[1] % pool_size
                X = X[:, :-overhang]
                if not self.only_predictions:
                    y = y[:, :-overhang]
                    sw = sw[:, :-overhang]
                    if self.predict_phase:
                        phases = phases[:, :-overhang]
                    if self.mode == 'train' and self.transition_weights is not None:
                        transitions = transitions[:, :-overhang]

            if not self.only_predictions:
                y = self._mk_timestep_pools_class_last(y)
                sw = sw.reshape((sw.shape[0], -1, pool_size))
                sw = np.logical_not(np.any(sw == 0, axis=2)).astype(np.int8)

            if self.mode == 'train':
                if self.class_weights is not None:
                    # class weights are additive for the individual timestep predictions
                    # giving even more weight to transition points
                    # class weights without pooling not supported yet
                    # cw = np.array([1.0, 1.2, 1.0, 0.8], dtype=np.float32)
                    cls_arrays = [np.any((y[:, :, :, col] == 1), axis=2) for col in range(4)]
                    cls_arrays = np.stack(cls_arrays, axis=2).astype(np.int8)
                    # add class weights to applicable timesteps
                    cw_arrays = np.multiply(cls_arrays, np.tile(self.class_weights, y.shape[:2] + (1,)))
                    cw = np.sum(cw_arrays, axis=2)
                    sw = np.multiply(cw, sw)

                # todo, while now compressed, the following is still 1:1 with LSTM model... --> HelixerModel
                if self.transition_weights is not None:
                    transitions = self._mk_timestep_pools_class_last(transitions)
                    # more reshaping and summing  up transition weights for multiplying with sample weights
                    sw_t = self.compress_tw(transitions)
                    sw = np.multiply(sw_t, sw)

                if self.coverage_weights:
                    coverage_scores = coverage_scores.reshape((coverage_scores.shape[0], -1, pool_size))
                    # maybe offset coverage scores [0,1] by small number (bc RNAseq has issues too), default 0.0
                    if self.coverage_offset > 0.:
                        coverage_scores = np.add(coverage_scores, self.coverage_offset)
                    coverage_scores = np.mean(coverage_scores, axis=2)
                    sw = np.multiply(coverage_scores, sw)

            if self.predict_phase and not self.only_predictions:
                y_phase = self._mk_timestep_pools_class_last(phases)
                y = [y, y_phase]

            return X, y, sw, transitions, phases, _, coverage_scores


class HelixerModel(ABC):
    def __init__(self, cli_args=None):
        self.cli_args = cli_args  # if cli_args is None, the parameters from sys.argv will be used

        self.parser = argparse.ArgumentParser()
        self.parser.add_argument('-d', '--data-dir', type=str, default=None)
        self.parser.add_argument('-s', '--save-model-path', type=str, default='./best_model.h5')
        self.parser.add_argument('--large-eval-folder', type=str, default='')
        # training params
        self.parser.add_argument('-e', '--epochs', type=int, default=10000)
        self.parser.add_argument('-b', '--batch-size', type=int, default=8)
        self.parser.add_argument('--val-test-batch-size', type=int, default=32)
        self.parser.add_argument('--loss', type=str, default='')
        self.parser.add_argument('--patience', type=int, default=3)
        self.parser.add_argument('--check-every-nth-batch', type=int, default=1_000_000)
        self.parser.add_argument('--optimizer', type=str, default='adamw')
        self.parser.add_argument('--clip-norm', type=float, default=3.0)
        self.parser.add_argument('--learning-rate', type=float, default=3e-4)
        self.parser.add_argument('--weight-decay', type=float, default=3.5e-5)
        self.parser.add_argument('--class-weights', type=str, default='None')
        self.parser.add_argument('--input-coverage', action='store_true', help=argparse.SUPPRESS)  # bc no models that can use this are available
        self.parser.add_argument('--coverage-norm', default=None, help=argparse.SUPPRESS)
        self.parser.add_argument('--transition-weights', type=str, default='None')
        self.parser.add_argument('--stretch-transition-weights', type=int, default=0, help=argparse.SUPPRESS)  # bc no clear effect on result quality
        self.parser.add_argument('--coverage-weights', action='store_true')
        self.parser.add_argument('--coverage-offset', type=float, default=0.0)
        self.parser.add_argument('--calculate-uncertainty', action='store_true')
        self.parser.add_argument('--no-utrs', action='store_true', help=argparse.SUPPRESS)  # is this still needed?
        self.parser.add_argument('--predict-phase', action='store_true')
        self.parser.add_argument('--load-predictions', action='store_true', help=argparse.SUPPRESS)  # bc no models that can use this are available
        self.parser.add_argument('--resume-training', action='store_true')
        # testing / predicting
        self.parser.add_argument('-l', '--load-model-path', type=str, default='')
        self.parser.add_argument('-t', '--test-data', type=str, default='')
        self.parser.add_argument('-p', '--prediction-output-path', type=str, default='predictions.h5')
        self.parser.add_argument('--compression', default='gzip', help='compression used for datasets in predictions '
                                                                       'h5 file. One of "lzf" or "gzip" (default)')
        self.parser.add_argument('--eval', action='store_true')
        self.parser.add_argument('--overlap', action="store_true",
                                 help="will improve prediction quality at 'chunk' ends by creating and overlapping "
                                      "sliding-window predictions (with proportional increase in time usage)")
        self.parser.add_argument('--overlap-offset', type=int, default=None,
                                 help="distance to 'step' between predicting subsequences when overlapping "
                                      "(default: subsequence_length / 2)")
        self.parser.add_argument('--core-length', type=int, default=None,
                                 help="length of 'core' subsequence to retain before overlapping. The ends beyond this"
                                      "region will be cropped. (default: subsequence_length * 3 / 4)")
        # resources
        self.parser.add_argument('--float-precision', type=str, default='float32')
        self.parser.add_argument('--cpus', type=int, default=8)
        self.parser.add_argument('--gpu-id', type=int, default=-1)
        self.parser.add_argument('--workers', type=int, default=1,
                                 help='consider setting to match the number of GPUs')
        # misc flags
        self.parser.add_argument('--save-every-check', action='store_true')
        self.parser.add_argument('--nni', action='store_true')
        self.parser.add_argument('-v', '--verbose', action='store_true')
        self.parser.add_argument('--debug', action='store_true')

    def parse_args(self):
        """Parses the arguments either from the command line via argparse by using self.parser or
        takes a list of cli arguments from self.cli_args. This can be used to invoke a HelixerModel from
        another script."""
        args = vars(self.parser.parse_args(args=self.cli_args))
        self.__dict__.update(args)

        if self.nni:
            hyperopt_args = nni.get_next_parameter()
            for key in hyperopt_args.keys():
                has_dash = key.find('-') > -1
                if key not in args:
                    if has_dash:
                        maybe_fixed = key.replace('-', '_')
                        raise AssertionError(f'Parameter from nni: "{key}" does not match parsed arguments.\n'
                                             f'Hint: "{key}" contains a "-"; maybe it should be "{maybe_fixed}" '
                                             'so as to match arguments parsed by ArgumentParser?')
                    else:
                        raise AssertionError(f'Parameter from nni: "{key}" does not match processed arguments')

            # cast int params to int as we may get them as float
            hyperopt_args = {name: (int(value) if isinstance(self.parser.get_default(name), int) else value)
                             for name, value in hyperopt_args.items()}
            # add args to class name space
            self.__dict__.update(hyperopt_args)
            nni_save_model_path = os.path.expandvars('$NNI_OUTPUT_DIR/best_model.h5')
            nni_pred_output_path = os.path.expandvars('$NNI_OUTPUT_DIR/predictions.h5')
            self.__dict__['save_model_path'] = nni_save_model_path
            self.__dict__['prediction_output_path'] = nni_pred_output_path
            args.update(hyperopt_args)
            # for the print out
            args['save_model_path'] = nni_save_model_path
            args['prediction_output_path'] = nni_pred_output_path

        self.testing = bool(self.load_model_path and not self.resume_training)
        self.only_predictions = (self.testing and not self.eval)  # do only load X in this case

        if not self.testing:
            assert self.data_dir is not None, '--data-dir required for training'

        assert not (not self.testing and self.test_data)
        assert not (self.resume_training and (not self.load_model_path or not self.data_dir))

        self.class_weights = eval(self.class_weights)
        if not isinstance(self.class_weights, (list, np.ndarray, type(None))):
            raise ValueError(f'--class-weights evaluated to {self.class_weights} of type {type(self.class_weights)}; '
                             f'this commonly means you need to remove nested quotes if not starting with nni')
        if type(self.class_weights) is list:
            self.class_weights = np.array(self.class_weights, dtype=np.float32)

        self.transition_weights = eval(self.transition_weights)
        if not isinstance(self.transition_weights, (list, np.ndarray, type(None))):
            raise ValueError(f'--transition-weights evaluated to {self.transition_weights} '
                             f'of type {type(self.transition_weights)}; '
                             f'this commonly means you need to remove nested quotes if not starting with nni')
        if type(self.transition_weights) is list:
            self.transition_weights = np.array(self.transition_weights, dtype=np.float32)

        if self.verbose:
            print(colored('HelixerModel config: ', 'yellow'))
            pprint(args)

    def generate_callbacks(self, train_generator):
        callbacks = [ConfusionMatrixTrain(self.save_model_path, train_generator, self.gen_validation_data(),
                                          self.large_eval_folder, self.patience, calc_H=self.calculate_uncertainty,
                                          report_to_nni=self.nni, check_every_nth_batch=self.check_every_nth_batch,
                                          save_every_check=self.save_every_check),
                     PreshuffleCallback(train_generator)]
        return callbacks

    def set_resources(self):
        gpu_devices = tf.config.experimental.list_physical_devices('GPU')
        for device in gpu_devices:
            tf.config.experimental.set_memory_growth(device, True)

        K.set_floatx(self.float_precision)
        if self.gpu_id > -1:
            tf.config.set_visible_devices([gpu_devices[self.gpu_id]], 'GPU')

    def gen_training_data(self):
        SequenceCls = self.sequence_cls()
        return SequenceCls(model=self, h5_files=self.h5_trains, mode='train', batch_size=self.batch_size,
                           shuffle=True)

    def gen_validation_data(self):
        SequenceCls = self.sequence_cls()
        return SequenceCls(model=self, h5_files=self.h5_vals, mode='val', batch_size=self.val_test_batch_size,
                           shuffle=False)

    def gen_test_data(self):
        SequenceCls = self.sequence_cls()
        return SequenceCls(model=self, h5_files=self.h5_tests, mode='test', batch_size=self.val_test_batch_size,
                           shuffle=False)

    @staticmethod
    def run_metrics(generator, model, print_to_stdout=True, calc_H=False):
        start = time.time()
        metrics_calculator = Metrics(generator, print_to_stdout=print_to_stdout,
                                     skip_uncertainty=not calc_H)
        metrics = metrics_calculator.calculate_metrics(model)
        genic_metrics = metrics['genic_base_wise']['genic']
        if np.isnan(genic_metrics['f1']):
            genic_metrics['f1'] = 0.0
        print('\nmetrics calculation took: {:.2f} minutes\n'.format(int(time.time() - start) / 60))
        return genic_metrics['precision'], genic_metrics['recall'], genic_metrics['f1']

    @staticmethod
    def run_large_eval(folder, model, generator, training_species, print_to_stdout=False, calc_H=False):
        def print_table(results, table_name, training_species):
            table = [['Name', 'Precision', 'Recall', 'F1-Score']]
            for name, values in results:
                if name.lower() in training_species:
                    name += ' (T)'
                table.append([name] + [f'{v:.4f}' for v in values])
            print('\n', AsciiTable(table, table_name).table, sep='')

        results = []
        training_species = [s.lower() for s in training_species]
        eval_file_names = glob.glob(f'{folder}/*.h5')
        for i, eval_file_name in enumerate(eval_file_names):
            h5_eval = h5py.File(eval_file_name, 'r')
            species_name = os.path.basename(eval_file_name).split('.')[0]
            print(f'\nEvaluating with a sample of {species_name} ({i + 1}/{len(eval_file_names)})')

            # possibly adjust batch size based on sample length, which could be flexible
            # assume the given batch size is for 20k length
            sample_len = h5_eval['data/X'].shape[1]
            adjusted_batch_size = int(generator.batch_size * (20000 / sample_len))
            print(f'adjusted batch size is {adjusted_batch_size}')

            # use exactly the data generator that is used during validation
            GenCls = generator.__class__
            gen = GenCls(model=generator.model, h5_file=h5_eval, mode='val',
                         batch_size=adjusted_batch_size, shuffle=False)
            perf_one_species = HelixerModel.run_metrics(gen, model, print_to_stdout=print_to_stdout, calc_H=calc_H)
            results.append([species_name, perf_one_species])
        # print results in tables sorted alphabetically and by f1
        results_by_name = sorted(results, key=lambda r: r[0])
        results_by_f1 = sorted(results, key=lambda r: r[1][2], reverse=True)
        print_table(results_by_name, 'Generalization Validation by Name', training_species)
        print_table(results_by_f1, 'Generalization Validation by Genic F1', training_species)

        # print one number summaries
        f1_scores = np.array([r[1][2] for r in results])
        in_train = np.array([r[0].lower() in training_species for r in results], dtype=np.bool)
        table = [['Metric', 'All', 'Training', 'Evaluation']]
        for name, func in zip(['Median F1', 'Average F1', 'Stddev F1'], [np.median, np.mean, np.std]):
            table.append([name, f'{func(f1_scores):.4f}',
                                f'{func(f1_scores[in_train]):.4f}',
                                f'{func(f1_scores[~in_train]):.4f}'])
        print('\n', AsciiTable(table, 'Summary').table, sep='')
        return np.median(f1_scores[~in_train])

    @abstractmethod
    def sequence_cls(self):
        pass

    @abstractmethod
    def model(self):
        pass

    @abstractmethod
    def compile_model(self, model):
        pass

    @staticmethod
    def plot_model(model):
        from tensorflow.keras.utils import plot_model
        plot_model(model, to_file='model.png')
        print('Plotted to model.png')
        sys.exit()

    @staticmethod
    def sum_shapes(datasets):
        shapes = [ds.shape for ds in datasets]
        return [sum(x[0] for x in shapes)] + list(shapes[0][1:])

    def open_data_files(self):
        def get_n_correct_seqs(h5_files):
            sum_n_correct = 0
            for h5_file in h5_files:
                if 'err_samples' in h5_file['/data'].keys():
                    err_samples = np.array(h5_file['/data/err_samples'])
                    n_correct = np.count_nonzero(err_samples == False)
                    if n_correct == 0:
                        print('WARNING: no fully correct sample found')
                else:
                    print('No err_samples dataset found, correct samples will be set to 0')
                    n_correct = 0
                sum_n_correct += n_correct
            return sum_n_correct

        def get_n_intergenic_seqs(h5_files):
            sum_n_fully_ig = 0
            for h5_file in h5_files:
                if 'fully_intergenic_samples' in h5_file['/data'].keys():
                    ic_samples = np.array(h5_file['/data/fully_intergenic_samples'])
                    n_fully_ig = np.count_nonzero(ic_samples == True)
                    if n_fully_ig == 0:
                        print('WARNING: no fully intergenic samples found')
                else:
                    print('No fully_intergenic_samples dataset found, fully intergenic samples will be set to 0')
                    n_fully_ig = 0
                sum_n_fully_ig += n_fully_ig
            return sum_n_fully_ig

        if not self.testing:
            self.h5_trains = [h5py.File(f, 'r') for f in glob.glob(os.path.join(self.data_dir, 'training_data*h5'))]
            self.h5_vals = [h5py.File(f, 'r') for f in glob.glob(os.path.join(self.data_dir, 'validation_data*h5'))]
            try:
                self.shape_train = self.sum_shapes([h5['/data/X'] for h5 in self.h5_trains])
            except IndexError as e:
                print('debugging info: self.h5_trains = {}, self.data_dir = {}'.format(self.h5_trains, self.data_dir),
                      file=sys.stderr)
                raise e
            try:
                self.shape_val = self.sum_shapes([h5['/data/X'] for h5 in self.h5_vals])
            except IndexError as e:
                print('debugging info: self.h5_vals = {}, self.data_dir = {}'.format(self.h5_vals, self.data_dir),
                      file=sys.stderr)
                raise e

            n_train_correct_seqs = get_n_correct_seqs(self.h5_trains)
            n_val_correct_seqs = get_n_correct_seqs(self.h5_vals)

            n_train_seqs = self.shape_train[0]
            n_val_seqs = self.shape_val[0]  # always validate on all

            n_intergenic_train_seqs = get_n_intergenic_seqs(self.h5_trains)
            n_intergenic_val_seqs = get_n_intergenic_seqs(self.h5_vals)
        else:
            self.h5_tests = [h5py.File(self.test_data, 'r')]  # list for consistency with train/val
            self.shape_test = self.h5_tests[0]['/data/X'].shape

            n_test_correct_seqs = get_n_correct_seqs(self.h5_tests)
            n_test_seqs_with_intergenic = self.shape_test[0]
            n_intergenic_test_seqs = get_n_intergenic_seqs(self.h5_tests)

        if self.verbose:
            print('\nData config: ')
            if not self.testing:
                print([dict(x.attrs) for x in self.h5_trains])
                print('\nTraining data/X shape: {}'.format(self.shape_train[:2]))
                print('Validation data/X shape: {}'.format(self.shape_val[:2]))
                print('\nTotal est. training sequences: {}'.format(n_train_seqs))
                print('Total est. val sequences: {}'.format(n_val_seqs))
                print('\nEst. intergenic train/val seqs: {:.2f}% / {:.2f}%'.format(
                    n_intergenic_train_seqs / n_train_seqs * 100,
                    n_intergenic_val_seqs / n_val_seqs * 100))
                print('Fully correct train/val seqs: {:.2f}% / {:.2f}%\n'.format(
                    n_train_correct_seqs / self.shape_train[0] * 100,
                    n_val_correct_seqs / self.shape_val[0] * 100))
            else:
                print([dict(x.attrs) for x in self.h5_tests])
                print('\nTest data shape: {}'.format(self.shape_test[:2]))
                print('\nIntergenic test seqs: {:.2f}%'.format(
                    n_intergenic_test_seqs / n_test_seqs_with_intergenic * 100))
                print('Fully correct test seqs: {:.2f}%\n'.format(
                    n_test_correct_seqs / self.shape_test[0] * 100))

    def _make_predictions(self, model):
        # loop through batches and continuously expand output dataset as everything might
        # not fit in memory
        pred_out = h5py.File(self.prediction_output_path, 'w')
        test_sequence = self.gen_test_data()

        for batch_index in range(len(test_sequence)):
            if self.verbose:
                print(batch_index, '/', len(test_sequence), end='\r')
            if not self.only_predictions:
                input_data = test_sequence[batch_index][0]
            else:
                input_data = test_sequence[batch_index]
            try:
                predictions = model.predict_on_batch(input_data)
            except Exception as e:
                print(colored('Errors at prediction often result from exhausting the GPU RAM.'
                              'Your RAM requirement depends on subsequence_length x (val_test_)batch_size.'
                              'That and the network size (can be changed during training but not inference).',
                              'red'))
                raise e
            if isinstance(predictions, list):
                # when we have two outputs, one is for phase
                output_names = ['predictions', 'predictions_phase']
            else:
                # if we just had one output
                predictions = (predictions,)
                output_names = ['predictions']

            for dset_name, pred_dset in zip(output_names, predictions):
                # join last two dims when predicting one hot labels
                pred_dset = pred_dset.reshape(pred_dset.shape[:2] + (-1,))
                # reshape when predicting more than one point at a time
                label_dim = 4
                if pred_dset.shape[2] != label_dim:
                    n_points = pred_dset.shape[2] // label_dim
                    pred_dset = pred_dset.reshape(
                        pred_dset.shape[0],
                        pred_dset.shape[1] * n_points,
                        label_dim,
                    )
                    # add 0-padding if needed
                    n_removed = self.shape_test[1] - pred_dset.shape[1]
                    if n_removed > 0:
                        zero_padding = np.zeros((pred_dset.shape[0], n_removed, pred_dset.shape[2]),
                                                dtype=pred_dset.dtype)
                        pred_dset = np.concatenate((pred_dset, zero_padding), axis=1)
                else:
                    n_removed = 0  # just to avoid crashing with Unbound Local Error setting attrs for dCNN

                if self.overlap:
                    pred_dset = test_sequence.ol_helper.overlap_predictions(batch_index, pred_dset)

                # prepare h5 dataset and save the predictions to disk
                pred_dset = pred_dset.astype(np.float16)
                if batch_index == 0:
                    old_len = 0
                    pred_out.create_dataset(dset_name,
                                            data=pred_dset,
                                            maxshape=(None,) + pred_dset.shape[1:],
                                            chunks=(1,) + pred_dset.shape[1:],
                                            dtype='float16',
                                            compression=self.compression,
                                            shuffle=True)
                else:
                    old_len = pred_out[dset_name].shape[0]
                    pred_out[dset_name].resize(old_len + pred_dset.shape[0], axis=0)
                pred_out[dset_name][old_len:] = pred_dset

        # add model config and other attributes to predictions
        h5_model = h5py.File(self.load_model_path, 'r')
        pred_out.attrs['model_config'] = h5_model.attrs['model_config']
        pred_out.attrs['n_bases_removed'] = n_removed
        pred_out.attrs['test_data_path'] = self.test_data
        pred_out.attrs['model_path'] = self.load_model_path
        pred_out.attrs['timestamp'] = str(datetime.datetime.now())
        if hasattr(self, 'loaded_model_hash'):
            pred_out.attrs['model_md5sum'] = self.loaded_model_hash
        pred_out.close()
        h5_model.close()

    def _print_model_info(self, model):
        pwd = os.getcwd()
        os.chdir(os.path.dirname(__file__))
        try:
            cmd = ['git', 'rev-parse', '--abbrev-ref', 'HEAD']
            branch = subprocess.check_output(cmd, stderr=subprocess.STDOUT).strip().decode()
            cmd = ['git', 'describe', '--always']  # show tag or hash if no tag available
            commit = subprocess.check_output(cmd, stderr=subprocess.STDOUT).strip().decode()
            print(f'Current Helixer branch: {branch} ({commit})')
        except subprocess.CalledProcessError:
            version = pkg_resources.require('helixer')[0].version
            print(f'Current Helixer version: {version}')

        try:
            if os.path.isfile(self.load_model_path):
                cmd = ['md5sum', self.load_model_path]
                self.loaded_model_hash = subprocess.check_output(cmd).strip().decode()
                print(f'Md5sum of the loaded model: {self.loaded_model_hash}')
        except subprocess.CalledProcessError:
            print('An error occurred while running a subprocess, unable to record loaded_model_hash')
            self.loaded_model_hash = 'error'

        print()
        if self.verbose:
            print(model.summary())
        else:
            print('Total params: {:,}'.format(model.count_params()))
        os.chdir(pwd)  # return to previous directory

    def run(self):
        self.set_resources()
        self.open_data_files()
        # we either train or predict
        if not self.testing:
            if self.resume_training:
                model = load_model(self.load_model_path)
            else:
                model = self.model()
            self._print_model_info(model)

            if self.optimizer.lower() == 'adam':
                self.optimizer = optimizers.Adam(learning_rate=self.learning_rate, clipnorm=self.clip_norm)
            elif self.optimizer.lower() == 'adamw':
                self.optimizer = AdamW(learning_rate=self.learning_rate, clipnorm=self.clip_norm,
                                       weight_decay=self.weight_decay)

            self.compile_model(model)

            train_generator = self.gen_training_data()
            model.fit(train_generator,
                      epochs=self.epochs,
                      workers=self.workers,
                      callbacks=self.generate_callbacks(train_generator),
                      verbose=True)
        else:
            assert self.test_data.endswith('.h5'), 'Need a h5 test data file when loading a model'
            assert self.load_model_path.endswith('.h5'), 'Need a h5 model file'

            strategy = tf.distribute.MirroredStrategy()
            print('Number of devices: {}'.format(strategy.num_replicas_in_sync))
            with strategy.scope():
                model = load_model(self.load_model_path)
            self._print_model_info(model)

            if self.eval:
                test_generator = self.gen_test_data()
                _, _, _ = HelixerModel.run_metrics(test_generator, model, calc_H=self.calculate_uncertainty)
                if self.large_eval_folder:
                    assert self.data_dir != '', 'need training data of the model for training genome names'
                    training_species = h5py.File(os.path.join(self.data_dir, 'training_data.h5'), 'r').attrs['genomes']
                    _ = HelixerModel.run_large_eval(self.large_eval_folder, model, test_generator, training_species,
                                                    print_to_stdout=True, calc_H=self.calculate_uncertainty)
            else:
                if os.path.isfile(self.prediction_output_path):
                    print(f'{self.prediction_output_path} already exists and will be overwritten.')
                self._make_predictions(model)
            for h5_test in self.h5_tests:
                h5_test.close()
