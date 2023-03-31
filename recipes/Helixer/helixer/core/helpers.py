import numpy as np

# some helpers for handling / sorting / or checking sort of our h5 files
def mk_seqonly_keys(h5):
    return [a + b for a, b in zip(h5['data/species'],
                                  h5['data/seqids'])]


def mk_keys(h5, flip=False):
    first_idx = 0
    second_idx = 1
    if flip:
        first_idx, second_idx = second_idx, first_idx
    return zip(h5['data/species'],
               h5['data/seqids'],
               h5['data/start_ends'][:, first_idx],
               h5['data/start_ends'][:, second_idx])


def get_sp_seq_ranges(h5):
    # dict with {sp: {"start: N,
    #                 "end": N,
    #                 "seqids": {seqid: [start, end], seqid2: [start2, end2], ...}},
    #            sp2: {...},
    #            ...}
    out = {}

    gen = zip(range(h5['data/y'].shape[0]), h5['data/species'], h5['data/seqids'])

    i, prev_sp, prev_seqid = next(gen)
    out[prev_sp] = {"start": i,  # 0
                    "seqids": {prev_seqid: [i]}}
    for i, sp, seqid in gen:
        if sp != prev_sp:
            # end previous sp and seqid
            out[prev_sp]["end"] = i
            out[prev_sp]["seqids"][prev_seqid].append(i)
            # open new
            out[sp] = {"start": i,
                       "seqids": {seqid: [i]}}
        elif seqid != prev_seqid:
            # end previous seqid
            out[sp]["seqids"][prev_seqid].append(i)
            # open new
            out[sp]["seqids"][seqid] = [i]
        prev_sp, prev_seqid = sp, seqid
    # end final sp/seqid
    out[prev_sp]["end"] = i + 1
    out[prev_sp]["seqids"][prev_seqid].append(i + 1)
    return out


# additional helping functions for predictions to hints, here so they can be tested
# also probably some redundancy with above to clean up (-_-)
def get_contiguous_ranges(h5):
    """gets h5 coordinates for same species, sequence and strand AKA end to end across a chromosome/scaffold"""
    start_ends = h5['data/start_ends'][:]
    marks_unique = np.stack((h5['data/seqids'], h5['data/species'], start_ends[:, 1] > start_ends[:, 0]))
    items, indexes, lengths = np.unique(marks_unique, axis=1, return_index=True, return_counts=True)
    reindex = np.argsort(indexes)
    for i in reindex:
        seqid, species, is_plus_strand = items[:, i]
        if is_plus_strand == b'True':
            bool_strand = True
        elif is_plus_strand == b'False':
            bool_strand = False
        else:
            raise ValueError('is_plus_strand somehow not True/False, instead it is {}'.format(is_plus_strand))
        yield {"species": species,
               "seqid": seqid,
               "is_plus_strand": bool_strand,
               "start_i": indexes[i],
               "end_i": indexes[i] + lengths[i]}


def read_in_chunks(preds, data, start_i, end_i, step=100):
    for i in range(start_i, end_i, step):
        ei = min(i + step, end_i)
        pred_chunk = preds['predictions'][i:ei]
        pred_chunk = pred_chunk.reshape((-1, 4))
        start = data['data/start_ends'][i, 0]
        end = data['data/start_ends'][ei - 1, 1]
        # in case of padding
        if abs(end - start) % data['data/X'].shape[1]:
            # padded areas have no sequence, so will use that to create a mask for simplicity
            mask = data['data/X'][i:ei].reshape((-1, 4))
            mask = np.any(mask, axis=1)
            pred_chunk = pred_chunk[mask]
            assert pred_chunk.shape[0] == abs(start - end)
        yield pred_chunk, start, end


def find_confident_single_class_regions(pred_chunk, pad=5):
    """find start, end (relative to pred_chunk) bits where in-between is confidently one class"""
    # in the event of a seamless class swap [1,0,0,0] -> [0,1,0,0]
    # and of a thin-seemed swap [1,0,0,0] -> [0.5,0.5,0,0] -> [0,1,0,0]
    # (and any easier swap, as well)
    # the 2-bp smoothing below will allow us to detect a class swap by drop in confidence (max)
    shift_n_averaged = (pred_chunk[:-1] + pred_chunk[1:]) / 2
    # find anywhere network was not confident / or class switch
    lowconf_idx = np.where(np.max(shift_n_averaged, axis=1) < 0.75001)[0]
    if lowconf_idx.shape[0] == 0:
        yield 0, pred_chunk.shape[0]
        return
    # handle (& yield) start of chunk edge case if pred_chunk starts with a confident region
    if lowconf_idx[0] > pad * 2:
        yield 0, lowconf_idx[0]
    # invert above to find longer single-class confident regions (double our padding)
    dist2next_lowconf = lowconf_idx[1:] - lowconf_idx[:-1]
    conf_sub_idx = np.where(dist2next_lowconf > pad * 2)[0]

    # yield confident regions
    for sub_idx in conf_sub_idx:
        start = lowconf_idx[sub_idx] + 1  # confidence starts _after_ lowconf ends
        end = start + dist2next_lowconf[sub_idx] - 1  # (exclusive) confidence ends where lowconf starts
        yield start, end

    # handle (& yield) end of chunk edge case if pred_chunk ends with a confident region
    if pred_chunk.shape[0] - lowconf_idx[-1] > pad * 2:
        yield lowconf_idx[-1] + 1, pred_chunk.shape[0]


def divvy_by_confidence(one_class_chunk, step_key, pad=5, stability_threshold=0.1):
    """breaks down contiguous 1-class region to pre-hints with semi-consistent confidence"""
    main_class = np.argmax(one_class_chunk[0])
    min_step, max_size = step_key[main_class]
    diffs = np.abs(one_class_chunk[:-1, main_class] - one_class_chunk[1:, main_class])
    cumulative_diffs = np.cumsum(diffs)
    # we start after padding (and end before), not necessarily at 0 nor sequence end
    cdiff_at_last_yield = cumulative_diffs[pad]
    end_of_last_yield = pad
    padded_seq_end = one_class_chunk.shape[0] - pad
    for i in range(pad, padded_seq_end, min_step):
        end = min(i + min_step, padded_seq_end)
        # if the total observed diffs since yield have passed the threshold, yield again
        # thus where confidence is volatile one gets small chunks, and for continuous predictions
        # one gets large (probably max_size) chunks (saves gff size & there's little gain in breaking down)
        if cumulative_diffs[end] - cdiff_at_last_yield > stability_threshold or \
                end - end_of_last_yield > max_size or \
                end == padded_seq_end:
            start = end_of_last_yield
            yield {'category': main_class,
                   'start': start,
                   'end': end,
                   'confidence': np.mean(one_class_chunk[start:end, main_class])}
            # reset trackers
            end_of_last_yield = end
            cdiff_at_last_yield = cumulative_diffs[end]

def file_stem(path):
    """Returns the file name without extension"""
    import os
    return os.path.basename(path).split('.')[0]
