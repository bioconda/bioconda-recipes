"""makes a copy of .h5 file with all fully erroneous and unannotated sequences removed"""
# this is for compatibility with previous runs or just
# convenience (e.g. making small data for quick testing / iteration)

import argparse
import h5py
import numpy as np


def fully_erroneous_masker(old, old_start, old_end):
    mask = np.logical_and(old['data/err_samples'][old_start:old_end],
                          old['data/is_annotated'][old_start:old_end])
    return mask


def mk_filter_fn(dataset, targets):
    targets = targets.split(',')
    targets = [x.encode('utf8') for x in targets]

    def filter_fn(old, old_start, old_end):
        mask = np.isin(old[dataset][old_start:old_end], targets)
        return mask

    return filter_fn


def main(data, out, write_by, h5_mask_only, fully_erroneous, keep_species, keep_seqids):
    old = h5py.File(data, mode='r')
    new = h5py.File(out, mode='a')

    # set mask file if necessary (i.e. if old contains only the dataset predictions, we'll need a sep. mask)
    if h5_mask_only is not None:
        mask_h5 = h5py.File(h5_mask_only, mode='r')
    else:
        mask_h5 = old

    end = mask_h5['data/X'].shape[0]

    # select filter function
    # check exactly one is set
    if np.sum([bool(x) for x in [fully_erroneous, keep_species, keep_seqids]]) == 1:
        if fully_erroneous:
            filter_fn = fully_erroneous_masker
        elif keep_species:
            filter_fn = mk_filter_fn(dataset='data/species', targets=keep_species)
        elif keep_seqids:
            filter_fn = mk_filter_fn(dataset='data/seqids', targets=keep_seqids)
        else:
            print(fully_erroneous, keep_species, keep_seqids)
            raise Exception('This should be unreachable')
    else:
        raise ValueError("exactly ONE of the parameters '--fully-erroneous', '--keep-species', or '--keep-seqids',"
                         "must be set. If more filters are needed, run twice. If no filtering is needed, don't run.")

    # setup all datasets that will need to be masked / filtered
    filter_keys = set(old.keys()).intersection({'data', 'evaluation', 'scores'})
    filter_datasets = []
    if 'predictions' in old.keys():
        filter_datasets.append('predictions')
    for key in filter_keys:
        filter_datasets += ['{}/{}'.format(key, x) for x in  old[key].keys()]
    for ds_key in filter_datasets:  # actually mk datasets
        new.create_dataset_like(ds_key, other=old[ds_key])

    # simply copy everything we don't know how to filter
    for key in old.keys():
        if key not in ['data', 'evaluation', 'predictions', 'scores']:
            bkey = key.encode('utf-8')
            h5py.h5o.copy(old.id, bkey, new.id, bkey)

    new_start = 0
    for old_start in range(0, end, write_by):
        old_end = min(old_start + write_by, end)
        mask = filter_fn(mask_h5, old_start, old_end)
        length = np.sum(mask)
        new_end = new_start + length
        # filter and copy over
        for ds_key in filter_datasets:
            new[ds_key][new_start:new_end] = old[ds_key][old_start:old_end][mask]
        new_start = new_end

    # truncate to length of new data
    for ds_key in filter_datasets:
        shape = list(new[ds_key].shape)
        new[ds_key].resize(tuple([new_start] + shape[1:]))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--h5-data', '-d', type=str, required=True, help='h5 file to filter')
    parser.add_argument('--h5-mask-only', type=str, help='h5 file to filter by (e.g. if h5-data has just predictions, '
                                                         'this can be the file the predictions were made from)')
    parser.add_argument('--h5-out', '-o', type=str, required=True, help='file for filtered output')
    parser.add_argument('--write-by', '-b', type=int, default=1000)
    parser.add_argument('--fully-erroneous', action='store_true')
    parser.add_argument('--keep-species', default=None, help='comma separated list of species to keep')
    parser.add_argument('--keep-seqids', default=None, help='comma separated list of seqids to keep')
    args = parser.parse_args()
    main(args.h5_data, args.h5_out, args.write_by, args.h5_mask_only, args.fully_erroneous,
         args.keep_species, args.keep_seqids)
