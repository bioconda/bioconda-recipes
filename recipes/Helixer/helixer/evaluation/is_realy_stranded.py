"""check whether the coverage actually looks like RNAseq reads come from a stranded protocol"""
import argparse
import h5py
from helixer.core.helpers import mk_keys


def match_strands(h5):
    """returns list of (idx +, idx -) tuples for matching positions in h5"""
    forward_keys = mk_keys(h5)
    reverse_keys = mk_keys(h5, flip=True)

    ## in place reminder from accs_genic_intergenic match_up, which works similarly
    #lab_keys = lab_keys[data_start_end[0]:data_start_end[1]]
    #pred_keys = pred_keys[pred_start_end[0]:pred_start_end[1]]

    #shared = list(set(lab_keys).intersection(set(pred_keys)))
    #lab_mask = [x in shared for x in lab_keys]
    #pred_mask = [x in shared for x in pred_keys]

    ## setup output arrays (with shared indexes)
    #labs = np.array(h5_data['data/y'][data_start_end[0]:data_start_end[1]])[lab_mask]
    #preds = np.array(h5_pred[h5_prediction_dataset][pred_start_end[0]:pred_start_end[1]])[pred_mask]
    #sample_weights = np.array(h5_data['data/sample_weights'][data_start_end[0]:data_start_end[1]][lab_mask])
    ## check if sorting matches
    #shared_lab_keys = np.array(lab_keys)[lab_mask]
    #shared_pred_keys = np.array(pred_keys)[pred_mask]
    #sorting_matches = np.all(shared_lab_keys == shared_pred_keys)

    ## resort both if not
    #if not sorting_matches:
    #    lab_lexsort = np.lexsort(np.flip(shared_lab_keys.T, axis=0))
    #    labs = labs[lab_lexsort]
    #    sample_weights = sample_weights[lab_lexsort]
    #    preds = preds[np.lexsort(np.flip(shared_pred_keys.T, axis=0))]
    #else:
    #    lab_lexsort = np.arange(labs.shape[0])
    #return labs, preds, lab_mask, lab_lexsort, sample_weights


def select_chunks(n, coverage_min, idx_pairs, h5):
    """takes random draws from idx_pairs until n pairs of chunks passing the coverage min have been found"""
    pass


def correlation_stats(chunk_pairs):
    """calculates std quantiles for the pearson correlation between all chunk_pairs"""
    pass


def main(h5_data, select_n, coverage_min):
    h5 = h5py.File(h5_data, 'r')
    idx_pairs = match_strands(h5)
    chunk_pairs = select_chunks(select_n, coverage_min, idx_pairs, h5)
    corr_quantiles = correlation_stats(chunk_pairs)
    # print / save results


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--h5_data', help="h5 produced by rnaseq.py")
    parser.add_argument('-n', '--select_n', help="base estimate on this many randomly selected chunks",
                        default=1000, type=int)
    parser.add_argument('-c', '--coverage_min', help="skip chunks with less than this mean coverage on either strand",
                        default=0.1, type=float)
    args = parser.parse_args()
    main(args.h5_data, args.select_n, args.coverage_min)
