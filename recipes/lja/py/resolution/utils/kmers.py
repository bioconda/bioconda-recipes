# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

from collections import Counter, defaultdict
import logging

from utils.various import fst_iterable, index

logger = logging.getLogger("centroFlye.utils.kmers")


def _split_seq_ignored_char(seq, ignored_chars=None):
    if ignored_chars is None:
        return [(0, seq)]
    i, j = 0, 0
    split_seqs = []
    while j < len(seq):
        if seq[j] in ignored_chars:
            if i != j:
                split_seq = seq[i:j]
                assert len(ignored_chars & set(split_seq)) == 0
                split_seqs.append((i, split_seq))
            i = j + 1
        j += 1
    if i < len(seq):
        assert len(ignored_chars & set(seq[i:])) == 0
        split_seqs.append((i, seq[i:]))
    return split_seqs


assert _split_seq_ignored_char((1, 2, '?', '*', 3, 4),
                               ignored_chars=set('?*')) == [(0, (1, 2)),
                                                            (4, (3, 4))]


def get_kmer_index_seq(seq, mink, maxk, ignored_chars=None, positions=False):
    kmer_index = get_kmer_index({'seq': seq},
                                mink=mink,
                                maxk=maxk,
                                ignored_chars=ignored_chars,
                                positions=positions)
    if positions:
        for k in range(mink, maxk+1):
            for kmer, pos in kmer_index[k].items():
                pos = [p[1] for p in pos]
                kmer_index[k][kmer] = pos
    return kmer_index


def get_kmer_index(seqs, mink, maxk, ignored_chars=None, positions=True):
    logger.info(f'Extracting kmer index mink={mink}, maxk={maxk} '
                f'Positions={positions}')
    assert 0 < mink <= maxk
    kmer_index = {k: defaultdict(set) for k in range(mink, maxk+1)}

    nseqs = len(seqs)
    logger.debug(f'Building index for maxk={maxk}')
    for i, (s_id, seq) in enumerate(seqs.items()):
        if i % 1000 == 0:
            logger.debug(f'{i+1} / {nseqs}')

        split_seqs = _split_seq_ignored_char(seq, ignored_chars=ignored_chars)

        for i, seq in split_seqs:
            if len(seq) < mink:
                continue
            k = min(maxk, len(seq))
            for j in range(len(seq)-k+1):
                kmer = seq[j:j+k]
                kmer_index[k][kmer].add((s_id, i+j))

    for k in range(maxk-1, mink-1, -1):
        logger.debug(f'Building index for k={k}')
        for kp1mer, pos in kmer_index[k+1].items():
            left_kmer = kp1mer[:-1]
            right_kmer = kp1mer[1:]
            kmer_index[k][left_kmer] |= pos
            kmer_index[k][right_kmer] |= \
                set((s_id, i+1) for (s_id, i) in pos)

    if not positions:
        for k in range(mink, maxk+1):
            kmer_index[k] = {kmer: len(pos)
                             for kmer, pos in kmer_index[k].items()}

    logger.info(f'Finished extracting kmer index')
    return kmer_index


def get_kmer_freqs_in_index(kmer_index, kmer_list):
    frequences = []
    for kmer in kmer_list:
        frequences.append(kmer_index[kmer])
    return frequences


def def_get_min_mult(k, mode):
    if mode == 'assembly':
        return 1
    if mode == 'hifi':
        if k <= 25:
            return 3
        else:
            # path graph construction
            return 1
    assert mode == 'ont'
    if k < 100:
        # not tested for k < 100
        return 20
    elif 100 <= k <= 300:
        return 15
    elif 300 < k <= 400:
        return 10
    elif 400 < k:
        # path graph construction
        return 1


def def_get_frequent_kmers(kmer_index, string_set,
                           min_mult, min_mult_rescue=4):
    min_mult_rescue = min(min_mult, min_mult_rescue)
    if min_mult > 1:
        assert min_mult_rescue > 1  # otherwise need to handle '?' symbs
    assert len(kmer_index) > 0
    k = len(fst_iterable(kmer_index))

    frequent_kmers = {kmer: len(pos) for kmer, pos in kmer_index.items()
                      if len(pos) >= min_mult}

    # s_id -> pos
    left_freq = defaultdict(lambda: 2**32)
    right_freq = defaultdict(int)

    for kmer in frequent_kmers:
        for s_id, p in kmer_index[kmer]:
            left_freq[s_id] = min(left_freq[s_id], p)
            right_freq[s_id] = max(right_freq[s_id], p)

    ext_frequent_kmers = {}
    for kmer, pos in kmer_index.items():
        if len(pos) < min_mult_rescue:
            continue
        for s_id, p in pos:
            if left_freq[s_id] <= p <= right_freq[s_id]:
                ext_frequent_kmers[kmer] = len(pos)
                break

    return ext_frequent_kmers


    def get_first_reliable(kmers):
        for i, kmer in enumerate(kmers):
            if kmer not in kmer_index:
                continue
            kmer_mult = kmer_index[kmer]
            if kmer_mult >= min_mult:
                return i
        return None

    for s_id, string in string_set.items():
        kmers = [tuple(string[i:i+k]) for i in range(len(string)-k+1)]
        left = get_first_reliable(kmers)
        if left is None:
            continue
        right = get_first_reliable(kmers[::-1])
        assert right is not None
        right = len(string) - k - right
        assert left <= right

        for i in range(left, right+1):
            kmer = string[i:i+k]
            kmer = tuple(kmer)
            if kmer not in kmer_index:
                continue
            kmer_mult = kmer_index[kmer]
            if kmer_mult >= min_mult_rescue:
                frequent_kmers[kmer] = kmer_mult
    return frequent_kmers


def get_gain(kmer, subst_monomer, kmer_index, string_set):
    k = len(kmer)
    assert k % 2 == 1
    k2 = k // 2
    central_monomer = kmer[k2]
    kmer_coords = kmer_index[kmer]
    gain = 0
    for s_id, pos in kmer_coords:
        string = string_set[s_id]
        bottom = max(0, pos-k2)
        top = 1 + min(pos+k2, len(string)-k)
        for p in range(bottom, top):
            i = pos-p+k2
            p_kmer = tuple(string[p:p+k])
            cnt_p_kmer = len(kmer_index[p_kmer])
            assert len(p_kmer) == k
            assert p_kmer[i] == central_monomer
            mut_kmer = list(p_kmer)
            mut_kmer[i] = subst_monomer
            mut_kmer = tuple(mut_kmer)
            cnt_mut_kmer = len(kmer_index[mut_kmer])
            gain += cnt_mut_kmer - cnt_p_kmer
    return gain, kmer_index


def correct_kmers(kmer_index_w_pos, string_set,
                  max_ident_diff=0.02):
    k = len(fst_iterable(kmer_index_w_pos))
    assert k % 2 == 1
    k2 = k//2
    km1mer2central = defaultdict(Counter)
    for kmer, pos in kmer_index_w_pos.items():
        km1mer = kmer[:k2] + kmer[k2+1:]
        central = kmer[k2]
        for s_id, p in pos:
            string = string_set[s_id]
            mi = string.monoinstances[p]
            if abs(mi.identity - mi.sec_identity) < max_ident_diff:
                km1mer2central[km1mer][central] += 1

    top_gain, top_subst = 0, None
    for km1mer, central_counter in km1mer2central.items():
        if len(central_counter) != 2:
            continue
        mono_ind1, mono_ind2 = central_counter
        cnt1, cnt2 = central_counter.values()
        kmer1 = km1mer[:k2] + (mono_ind1,) + km1mer[k2:]
        kmer2 = km1mer[:k2] + (mono_ind2,) + km1mer[k2:]
        assert kmer1 in kmer_index_w_pos
        assert kmer2 in kmer_index_w_pos

        gain12, _ = get_gain(kmer=kmer1,
                             subst_monomer=mono_ind2,
                             kmer_index=kmer_index_w_pos,
                             string_set=string_set)

        gain21, _ = get_gain(kmer=kmer2,
                             subst_monomer=mono_ind1,
                             kmer_index=kmer_index_w_pos,
                             string_set=string_set)
        if gain12 > top_gain:
            top_gain = gain12
            top_subst = (kmer1, mono_ind2)
        if gain21 > top_gain:
            top_gain = gain21
            top_subst = (kmer2, mono_ind1)
    print(f'Top gain = {top_gain}')
    return top_subst


def keep_shortest_lists(lst):
    to_remove = set()
    for l1 in lst:
        for l2 in lst:
            if l1 == l2:
                continue
            if len(index(l1, l2)):
                to_remove.add(l1)
    return [l for l in lst if l not in to_remove]
