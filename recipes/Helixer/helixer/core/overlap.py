#! /usr/bin/env python3

"""handler code for sliding window predictions and re-overlapping things back to original sequences"""

import numpy as np
import math
import sys


def _n_ori_chunks_from_batch_chunks(max_batch_size, overlap_offset, chunk_size):
    """check max number of original (non overlapped) chunks that fit in overlapped batch_size (or remaining)"""
    # this is going to be empirical for A simplicity and B maintainability
    end = 0
    empirical_bs = 0
    while empirical_bs <= max_batch_size:
        end += 1
        sb = SubBatch(tuple(range(end)), edge_handle_start=False, edge_handle_end=False, is_plus_strand=True,
                      overlap_offset=overlap_offset, chunk_size=chunk_size)
        empirical_bs = sb.sub_batch_size

    return end - 1  # the while loop only breaks _after_ overshooting max


class SubBatch:

    def __init__(self, h5_indices, edge_handle_start, edge_handle_end, is_plus_strand,
                 overlap_offset, chunk_size, keep_start=None, keep_end=None):
        self.h5_indices = h5_indices
        # the following parameters are primarily for debugging
        self.keep_start = keep_start
        self.keep_end = keep_end
        # if not on a sequence edge start and end bits will be cropped
        # also, start on negative strand would ideally have special handling for weird padding
        self.edge_handle_start = edge_handle_start
        self.edge_handle_end = edge_handle_end
        self.is_plus_strand = is_plus_strand
        self.overlap_depth = math.ceil(chunk_size / overlap_offset)
        self.overlap_offset = overlap_offset
        self.chunk_size = chunk_size
        self.sliding_coordinates = self._mk_sliding_coordinates()
        self.sub_batch_size = len(self.sliding_coordinates)

    def __repr__(self):
        sstr, estr = '(', ')'

        if self.edge_handle_end:
            estr = ']'
        if self.edge_handle_start:
            sstr = '['

        return 'SubBatch, {}edges{}, h5 indices: {}'.format(sstr, estr, self.h5_indices)

    @property
    def seq_length(self):
        return self.chunk_size * len(self.h5_indices)

    def _mk_sliding_coordinates(self):
        out = []
        for i in range(0, self.seq_length - self.chunk_size + 1, self.overlap_offset):
            out.append((i, i + self.chunk_size))
        # add one final one for special case with uneven fit
        # [chunkCHUNK] with offset 3 characters
        # [00000     ]
        #     11111  ]
        #        2222]2   <--- not this X
        #       22222]    <--- but this :-)
        if out[-1][1] < self.seq_length:
            out.append((self.seq_length - self.chunk_size, self.seq_length))
        return tuple(out)

    def mk_sliding_overlaps_for_data_sub_batch(self, data_sub_batch):
        """makes sliding window of input data (x, or coverage data)"""
        # combine first 2 dimensions (i.e. merge chunks)
        dat = data_sub_batch.reshape([np.prod(data_sub_batch.shape[:2])] + list(data_sub_batch.shape[2:]))
        sliding_dat = [dat[start:end] for start, end in self.sliding_coordinates]
        return sliding_dat

    def _overlap_preds(self, preds, core_length):
        """take sliding-window predictions, and overlap (w/end clipping) to generate original coordinate predictions"""
        trim_by = (self.chunk_size - core_length) // 2
        ydim = preds[0].shape[-1]
        if ydim == self.chunk_size:
            ydim = 1
        preds_out = np.zeros(shape=(self.seq_length, ydim))
        counts = np.zeros(shape=(self.seq_length, 1))

        len_preds = len(preds)
        for i, chunk, start_end in zip(range(len_preds), preds, self.sliding_coordinates):
            start, end = start_end
            # cut to core, (but not sequence ends)
            if trim_by > 0:
                if i > 0:  # all except first seq
                    start += trim_by
                    chunk = chunk[trim_by:]
                if i < len_preds - 1:  # all except last seq
                    end -= trim_by
                    chunk = chunk[:-trim_by]
            elif trim_by < 0:  # sanity check only
                raise ValueError('invalid trim value: {}. Maybe core_length {} > chunk_size {}?'.format(
                    trim_by, core_length, chunk.shape[0]))
            sub_counts = counts[start:end]
            # average weighted by number of predictions counted at position so far
            preds_out[start:end] = (preds_out[start:end] * sub_counts + chunk) / (sub_counts + 1)
            # increment counted so far
            counts[start:end] += 1
        preds_out = preds_out.reshape((len(self.h5_indices), self.chunk_size, ydim))
        return preds_out

    def overlap_and_edge_handle_preds(self, preds, core_length):
        """overlaps sliding predictions, then crops as necessary on edges"""
        # the final sequences for what is cropped will come from previous/next batch instead
        # i.e. this should produce identical output regardless of batch size
        # as avoidable batch/sub-batch edge effects will be complete cropped here.
        clean_preds = self._overlap_preds(preds, core_length)
        clean_preds = self.edge_handle(clean_preds)
        return clean_preds

    def edge_handle(self, dat):
        """crops first and second array from output unless at sequence edge"""
        if not self.edge_handle_start:
            dat = dat[1:]
        if not self.edge_handle_end:
            dat = dat[:-1]
        return dat


# places where overlap will affect core functionality of HelixerSequence
class OverlapSeqHelper(object):
    """handles overlap-ready batching, as well as overlap-prep and overlapping there-of"""
    def __init__(self, contiguous_ranges, chunk_size, max_batch_size, overlap_offset, core_length):
        # check validity of settings
        self.max_batch_size = max_batch_size
        self.core_length = core_length
        if chunk_size % overlap_offset:
            print("chunk size is not divisible by overlap_offset, so coverage depth"
                  "during overlapping will vary by 1", file=sys.stderr)

        assert overlap_offset <= core_length, "change settings to over-, not under-lap (offset < core length)"
        assert core_length > 0
        assert overlap_offset > 0

        # contiguous ranges should be created by .helpers.get_contiguous_ranges
        self.sliding_batches = self._mk_sliding_batches(contiguous_ranges=contiguous_ranges,
                                                        chunk_size=chunk_size,
                                                        overlap_offset=overlap_offset)

    def _mk_sliding_batches(self, contiguous_ranges, chunk_size, overlap_offset):
        # max_n_chunks is the number of chunks that will go into overlapping
        # before any sliding window, before any dropping or clipping
        max_n_chunks = _n_ori_chunks_from_batch_chunks(self.max_batch_size, overlap_offset, chunk_size)
        # make sure we can drop first and last (to produce same results, regardless of batch size)
        # and still have one chunk
        assert max_n_chunks >= 3, "batch_size is set too small to functionally overlap, " \
                                 "either a) set higher (to ~ 2 * chunk_size / overlap_offset + 1), " \
                                 "b) increase overlap_offset, or c) don't overlap"
        step = max_n_chunks - 2   # -2 bc ends will be cropped
        # most of these will effectively be final batches, but short seqs/ends may be grouped together (for efficiency)
        sub_batches = []

        for crange in contiguous_ranges:
            # step through sequence so that non-edges can have 1-chunk cropped off start/end
            # and regenerate original sequence with a simple concatenation there after
            for i in range(crange['start_i'], crange['end_i'], step):
                sub_batch_start = max(i - 1, crange['start_i'])  # pad 1 left (except seq edge)
                keep_start = max(i, crange['start_i'])
                keep_end = min(i + step, crange['end_i'])
                sub_batch_end = min(i + step + 1, crange['end_i'])   # pad 1 right (except seq edge)
                h5_indices = tuple(range(sub_batch_start, sub_batch_end))
                sub_batches.append(
                    SubBatch(h5_indices, is_plus_strand=crange['is_plus_strand'],
                             edge_handle_start=i == crange['start_i'],
                             edge_handle_end=i + step + 1 > crange['end_i'],
                             keep_start=keep_start,
                             keep_end=keep_end,
                             overlap_offset=overlap_offset, chunk_size=chunk_size)
                )

        # group into final batches, so as to keep total size <= max_batch_size
        # i.e. achieve consistent (& user adjustable) memory usage on graphics card
        sliding_batches = []
        batch = []
        batch_total_size = 0
        for sb in sub_batches:
            if batch_total_size + sb.sub_batch_size <= self.max_batch_size:
                batch.append(sb)
                batch_total_size += sb.sub_batch_size
            else:
                sliding_batches.append(batch)
                batch = [sb]
                batch_total_size = sb.sub_batch_size
        sliding_batches.append(batch)
        return sliding_batches

    def adjusted_epoch_length(self):
        """number of batches per epoch (given that we're overlapping)"""
        return len(self.sliding_batches)

    def h5_indices_of_batch(self, batch_idx):
        """concatenate indices from sub batches to give all indices for the batch at {batch_idx}"""
        sub_batches = self.sliding_batches[batch_idx]
        h5_indices = []
        for sb in sub_batches:
            h5_indices += sb.h5_indices
        return np.array(h5_indices)

    def make_input(self, batch_idx, data_batch):
        """make sliding input for prediction and overlapping (i.e. for X, maybe also for coverage)"""
        sub_batches = self.sliding_batches[batch_idx]
        sb_input_lengths = [len(sb.h5_indices) for sb in sub_batches]
        sb_input_starts = np.cumsum(sb_input_lengths) - sb_input_lengths
        x_as_list = []
        for start, length, sb in zip(sb_input_starts, sb_input_lengths, sub_batches):
            x_as_list.append(sb.mk_sliding_overlaps_for_data_sub_batch(data_batch[start:(start + length)]))
        sliding_input = np.concatenate(x_as_list)
        return sliding_input

    def overlap_predictions(self, batch_idx, predictions):
        """overlapping of sliding predictions to regenerate original dimensions"""
        sub_batches = self.sliding_batches[batch_idx]
        sub_batch_lengths = [sb.sub_batch_size for sb in sub_batches]
        sub_batch_starts = np.cumsum(sub_batch_lengths) - sub_batch_lengths
        out = []
        for start, length, sb in zip(sub_batch_starts, sub_batch_lengths, sub_batches):
            preds = predictions[start:(start + length)]
            out.append(sb.overlap_and_edge_handle_preds(preds, self.core_length))
        out = np.concatenate(out)
        n_expect = np.sum([sb.keep_end - sb.keep_start for sb in sub_batches])
        assert out.shape[0] == n_expect, f'overlapping trouble, maybe try a higher batch-size? ' \
                                         f'(debug info: got {out.shape[0]}, expected {n_expect},' \
                                         f'sub batches: {sub_batches})'
        return out

    def subset_input(self, batch_idx, y_true_or_sw):
        """generate subset from data corresponding to _final_ predictions, i.e. to run y_true through during eval"""
        sub_batches = self.sliding_batches[batch_idx]
        sb_input_lengths = [len(sb.h5_indices) for sb in sub_batches]
        sb_input_starts = np.cumsum(sb_input_lengths) - sb_input_lengths
        dat_as_list = []
        for start, length, sb in zip(sb_input_starts, sb_input_lengths, sub_batches):
            dat_as_list.append(sb.edge_handle(y_true_or_sw[start:(start + length)]))
        return np.concatenate(dat_as_list)
