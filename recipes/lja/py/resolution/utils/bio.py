# (c) 2019 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

from Bio import SeqIO
import numpy as np
import edlib
from itertools import groupby
import os
import re
import textwrap

from joblib import Parallel, delayed

from utils.various import weighted_random_by_dct


script_dir = os.path.dirname(os.path.realpath(__file__))


def read_bio_seq(filename):
    seqs = read_bio_seqs(filename)
    return str(list(seqs.values())[0])


def read_bio_seqs(filename):
    form = filename.split('.')[-1]
    if form == 'fa' or form == 'fna':
        form = 'fasta'
    elif form == 'fq':
        form = 'fastq'
    seqs = SeqIO.parse(filename, format=form)
    seqs = {seq.id: str(seq.seq) for seq in seqs}
    return seqs


trans = str.maketrans('ATGCatgc-', 'TACGtacg-')


def RC(s):
    return s.translate(trans)[::-1]


def write_bio_seqs(filename, seqs, width=60):
    with open(filename, 'w') as f:
        for seq_id, seq in seqs.items():
            print(f'>{seq_id}', file=f)
            if width is None:
                print(seq, file=f)
                continue
            start=0
            seq_len = len(seq)
            while seq_len - start >= width:
                print(seq[start:start+width], file=f)
                start += width
            print(seq[start:], file=f)

def reverse_seq(seq):
    rev_seq = list(seq[::-1])
    for i in range(len(rev_seq)):
        if rev_seq[i] == 'R':
            continue
        sign = rev_seq[i][0]
        if sign == '+':
            rev_seq[i] = '-' + rev_seq[i][1:]
        elif sign == '-':
            rev_seq[i] = '+' + rev_seq[i][1:]
        else:
            raise ValueError
    return rev_seq


def gen_random_seq(length, bases=list("ACGT")):
    indexes = np.random.randint(len(bases), size=length)
    sequence = ''.join([bases[i] for i in indexes])
    return sequence


def compress_homopolymer(seq, return_list=False):
    compressed_seq = [x[0] for x in groupby(list(seq))]
    if return_list:
        return compressed_seq
    return ''.join(compressed_seq)


def hamming_distance(s1, s2, match_char=set()):
    # assert len(s1) == len(s2)
    nucl_ident = []
    for x, y in zip(s1, s2):
        if x in match_char or y in match_char:
            nucl_ident.append(0)
        else:
            nucl_ident.append(x != y)
    return sum(nucl_ident), len(nucl_ident)


def identity_shift(s1, s2, min_overlap, match_char=set()):
    best_identity, best_shift, best_hd, best_len = 0, None, None, None
    alt_shifts = []
    for shift in range(len(s1) - min_overlap):
        hd, cur_length = \
            hamming_distance(s1[shift:], s2, match_char=match_char)
        identity = 1 - hd / cur_length
        if identity == best_identity:
            alt_shifts.append(shift)
        if identity > best_identity:
            best_identity = identity
            best_shift = shift
            best_hd = hd
            best_len = cur_length
            alt_shifts = []
    return {'id': best_identity, 'shift': best_shift,
            'hd': best_hd, 'len': best_len,
            'alt_shifts': alt_shifts}


def OverlapAlignment(s1, s2, mismatch, sigma):
    n, m = len(s1) + 1, len(s2) + 1
    s1 = ' ' + s1
    s2 = ' ' + s2

    def cell(prev, char, score):
        return {'prev': prev, 'char': char, 'score': score}

    w = [[0] * m for i in range(n)]
    # for i in range(1, n):
    #     w[i][0] = w[i-1][0] - sigma
    for j in range(1, m):
        w[0][j] = w[0][j-1] - sigma

    for i in range(1, n):
        for j in range(1, m):
            a = w[i-1][j-1] + (1 if s1[i] == s2[j] else -mismatch)
            b, c = w[i-1][j] - sigma, w[i][j-1] - sigma
            w[i][j] = max(a, b, c)

    lrow_max = max(w[-1])
    jmax = [j for j in range(1, m) if w[-1][j] == lrow_max][0]
    a1, a2 = [], []
    i, j = n-1, jmax
    while i != 0 and j != 0:
        if w[i][j] == w[i-1][j-1] + (1 if s1[i] == s2[j] else -mismatch):
            a1.append(s1[i])
            a2.append(s2[j])
            i, j = i-1, j-1
        elif w[i][j] == w[i-1][j] - sigma:
            a1.append(s1[i])
            a2.append('-')
            i, j = i-1, j
        elif w[i][j] == w[i][j-1] - sigma:
            a1.append('-')
            a2.append(s2[j])
            i, j = i, j-1

    a1 = ''.join(a1[::-1])
    a2 = ''.join(a2[::-1])

    a1 = s1[1:(i+1)] + '|' + a1
    a2 = '-' * i + '|' + a2

    a1 += '|' + '-' * (m-jmax-1)
    a2 += '|' + s2[jmax+1:]

    assert len(a1) == len(a2)

    return w[n-1][jmax], a1, a2, i


def parse_cigar(cigar, s1=None, s2=None):
    parsed_cigar = []
    st = 0
    cnt = dict.fromkeys(list("=XID"), 0)
    for mo in re.finditer(r'=|X|I|D', cigar):
        group = mo.group()
        pos = mo.start()
        region_len = int(cigar[st:pos])
        parsed_cigar.append((region_len, group))
        cnt[group] += region_len
        st = pos + 1
    if s1 is None or s2 is None:
        return parsed_cigar, cnt

    a1, a2 = [], []
    i1, i2 = 0, 0
    for region_len, group in parsed_cigar:
        if group in '=X':
            new_s1 = s1[i1:i1+region_len]
            new_s2 = s2[i2:i2+region_len]
            # if group == '=':
            #     assert new_s1 == new_s2
            a1 += new_s1
            a2 += new_s2
            i1 += region_len
            i2 += region_len
        elif group == 'D':
            a1 += '-' * region_len
            a2 += s2[i2:i2+region_len]
            i2 += region_len
        elif group == 'I':
            a2 += '-' * region_len
            a1 += s1[i1:i1+region_len]
            i1 += region_len

    # a1 = ''.join(a1)
    # a2 = ''.join(a2)
    return parsed_cigar, cnt, a1, a2


assert parse_cigar('89=1X6=3X76=') == ([(89, '='), (1, 'X'), (6, '='), (3, 'X'), (76, '=')],
                                       {'=': 171, 'X': 4, 'I': 0, 'D': 0})


def min_cyclic_shift(s):
    ds = s + s
    min_shift = min(ds[i:i+len(s)] for i in range(len(s)))
    return min_shift


def get_mut_config(data_type):
    if data_type == 'pacbio':
        config_fn = os.path.join(script_dir, '..', '..',
                                 'config', 'pacbio_substitutions.mat')
    elif data_type == 'nano':
        config_fn = os.path.join(script_dir, '..', '..',
                                 'config', 'nano_r94_substitutions.mat')
    else:
        assert False, f'Unknown: {data_type}. "pacbio"/"nano are supported'

    subst = {b: {} for b in list("ACGT")}
    ins = {}

    with open(config_fn) as f:
        for line in f:
            line = line.strip().split('\t')
            action = line[0]
            if action == 'mat':
                b, p = line[1], float(line[2])
                subst[b][b] = p
            elif action == 'mis':
                p = line[2]
                (s, e), p = line[1].split('->'), float(p)
                subst[s][e] = p
            elif action == 'del':
                b, p = line[1], float(line[2])
                subst[b][''] = p
            elif action == 'ins':
                b, p = line[1], float(line[2])
                ins[b] = p
            elif action == 'noins':
                p = float(line[1])
                ins[''] = p
    return subst, ins


def __mutate_seq(seq, subst, ins):
    mut = []
    for b in seq:
        ins_b = weighted_random_by_dct(ins)
        mut.append(ins_b)
        mut_b = weighted_random_by_dct(subst[b])
        mut.append(mut_b)
    mut = ''.join(mut)
    return mut


def mutate_seq(seq, data_type, N=1, t=16):
    subst, ins = get_mut_config(data_type)

    if N < 100:
        mut_seqs = []
        for i in range(N):
            mut_seqs.append(__mutate_seq(seq, subst, ins))
    else:
        mut_seqs = Parallel(n_jobs=t) \
            (delayed(__mutate_seq)(seq, subst, ins) for i in range(N))

    if N == 1:
        return mut_seqs[0]
    return mut_seqs


def hybrid_alignment(r, a, b, mism=-1, match=1, indel=-1):

    def dp(r, a, b, lr, la, lb):
        ra = np.zeros((lr, la))
        rb = np.zeros((lr, lb))
        rap = np.zeros((lr, la), dtype=tuple)
        rbp = np.zeros((lr, lb), dtype=tuple)

        # matrix ra
        ## initialize 0th column
        for i in range(1, lr):
            ra[i, 0] = ra[i-1, 0] + indel
        ## initialize 0th row
        for j in range(1, la):
            ra[0, j] = ra[0, j-1] + indel
        ## main dp for ra
        for i in range(1, lr):
            for j in range(1, la):
                diag = ra[i-1, j-1] + match if r[i] == a[j] else mism
                vert = ra[i-1, j] + indel
                horz = ra[i, j-1] + indel

                score = max(diag, vert, horz)
                if diag == score:
                    ra[i, j] = diag
                    rap[i, j] = (i-1, j-1)
                elif vert == score:
                    ra[i, j] = vert
                    rap[i, j] = (i-1, j)
                elif horz == score:
                    ra[i, j] = horz
                    rap[i, j] = (i, j-1)
                else:
                    assert False

        # matrix rb
        ## initialize 0th column
        for i in range(1, lr):
            rb[i, 0] = rb[i-1, 0] + indel
            rbp[i, 0] = (1, i-1, 0)
            for j in range(0, la):
                jump = ra[i, j]
                if jump > rb[i, 0]:
                    rb[i, 0] = jump
                    rbp[i, 0] = (0, i, j)
        ## initialize 0th row
        for j in range(0, lb):
            rbp[0, j] = (0, 0, 0)
        ## main dp for rb
        for i in range(1, lr):
            for j in range(1, lb):
                best_jump = -1
                for k in range(0, la):
                    jump = ra[i, k]
                    if jump > best_jump:
                        best_jump = jump
                        rbp[i, j] = (0, i, k)
                rb[i, j] = best_jump

                diag = rb[i-1, j-1] + match if r[i] == b[j] else mism
                vert = rb[i-1, j] + indel
                horz = rb[i, j-1] + indel
                score = max(rb[i, j], diag, vert, horz)

                if diag == score:
                    rb[i, j] = diag
                    rbp[i, j] = (1, i-1, j-1)
                elif vert == score:
                    rb[i, j] = vert
                    rbp[i, j] = (1, i-1, j)
                elif horz == score:
                    rb[i, j] = horz
                    rbp[i, j] = (1, i, j-1)
        return ra, rb, rap, rbp

    # backtracking
    def simp_back(p, m, i, j):
        ar, am = [], []
        while i != 0 and j != 0:
            if p[i, j] == (i-1, j-1):
                ar.append(r[i])
                am.append(m[j])
                i -= 1
                j -= 1
            elif p[i, j] == (i-1, j):
                ar.append(r[i])
                am.append('-')
                i -= 1
            else:
                ar.append('-')
                am.append(m[j])
                j -= 1

        while i != 0:
            ar.append(r[i])
            am.append('-')
            i -= 1
        while j != 0:
            ar.append('-')
            am.append(m[j])
            j -= 1
        ar.reverse()
        am.reverse()
        return ar, am

    def jump_back(p0, p1, m0, m1, i, j):
        ar, am = [], []
        while i != 0 and j != 0:
            if p1[i, j] == (1, i-1, j-1):
                ar.append(r[i])
                am.append(m1[j])
                i -= 1
                j -= 1
            elif p1[i, j] == (1, i-1, j):
                ar.append(r[i])
                am.append('-')
                i -= 1
            elif p1[i, j] == (1, i, j-1):
                ar.append('-')
                am.append(m1[j])
                j -= 1
            elif p1[i, j][0] == 0:
                i0, j0 = p1[i, j][1:]
                assert i0 == i
                ar0, am0 = simp_back(p0, m0, i0, j0)
                ar.reverse()
                am.reverse()
                ar = ar0 + ar
                am = am0 + am
                return ar, am, (i, j, j0)
        while i != 0:
            if p1[i, 0][0] == 0:
                j0 = p1[i, 0][2]
                ar0, am0 = simp_back(p0, m0, i, j0)
                ar.reverse()
                am.reverse()
                ar = ar0 + ar
                am = am0 + am
                return ar, am, (i, 0, j0)
            else:
                ar.append(r[i])
                am.append('-')
                i -= 1
        return ar, am, None

    lr, la, lb = len(r) + 1, len(a) + 1, len(b) + 1
    r, a, b = ' ' + r, ' ' + a, ' ' + b

    ab_ra, ab_rb, ab_rap, ab_rbp = dp(r=r, a=a, b=b, lr=lr, la=la, lb=lb)
    ba_rb, ba_ra, ba_rbp, ba_rap = dp(r=r, a=b, b=a, lr=lr, la=lb, lb=la)

    ab_a_sc, ab_b_sc = ab_ra[-1, -1], ab_rb[-1, -1]
    ba_a_sc, ba_b_sc = ba_ra[-1, -1], ba_rb[-1, -1]

    # print(f'ab_a_sc = {ab_a_sc}, ab_b_sc = {ab_b_sc}')
    # print(f'ba_b_sc = {ba_b_sc}, ba_a_sc = {ba_a_sc}')

    scores = sorted([ab_a_sc, ab_b_sc, ba_a_sc, ba_b_sc], reverse=True)
    score, sec_score = scores[:2]
    score = max(ab_a_sc, ab_b_sc, ba_a_sc, ba_b_sc)
    if ab_a_sc == score:
        alr, alm = simp_back(p=ab_rap, m=a, i=lr-1, j=la-1)
        jump = None
        orient = '>'
    elif ab_b_sc == score:
        alr, alm, jump = jump_back(p0=ab_rap, p1=ab_rbp,
                                   m0=a, m1=b,
                                   i=lr-1, j=lb-1)
        orient = '>'
    elif ba_b_sc == score:
        alr, alm = simp_back(p=ba_rbp, m=b, i=lr-1, j=lb-1)
        jump = None
        orient = '<'
    elif ba_a_sc == score:
        alr, alm, jump = jump_back(p0=ba_rbp, p1=ba_rap,
                                   m0=b, m1=a,
                                   i=lr-1, j=la-1)
        orient = '<'
    else:
        assert False

    alr, alm = ''.join(alr), ''.join(alm)
    return alr, alm, score, sec_score, jump, orient


def calc_identity(a, b, mode='NW', k=None):
    alignment = edlib.align(a, b, task='path', mode=mode, k=k)
    if alignment['editDistance'] == -1:
        return 0, alignment
    cigar, cigar_stats = parse_cigar(alignment['cigar'])
    alignment_len = sum(cigar_stats.values())
    identity = 1 - alignment['editDistance'] / alignment_len
    assert 0 <= identity <= 1
    return identity, alignment


def group_cuts(s1, s2):
    a1, a2 = parse_cigar(edlib.align(s1, s2, task='path')['cigar'], s1, s2)[2:]
    a1 += '1'
    a2 += '2'
    i, j = 0, 0
    m_regs = []
    st1, st2 = 0, 0
    for k, (c1, c2) in enumerate(zip(a1, a2)):

        if c1 != c2 and st1 < i and st2 < j:
            m_regs.append(((st1, i), (st2, j)))

        if c1 != '-':
            i += 1
        if c2 != '-':
            j += 1

        if c1 != c2:
            st1, st2 = i, j

    for (st1, en1), (st2, en2) in m_regs:
        assert s1[st1:en1] == s2[st2:en2]
    return m_regs


def print_alignment(s1, s2, k=None, mode='NW', width=60):
    if k is None:
        k = max(len(s1), len(s2))
    alignment = edlib.align(s1, s2, task='path', k=k, mode=mode)
    cigar = alignment['cigar']
    locs = alignment['locations']
    st, en = locs[0]
    _, _, a1, a2 = parse_cigar(cigar, s1, s2[st:])
    status = []
    for c1, c2 in zip(a1, a2):
        if c1 == c2:
            status.append('|')
        elif c1 == '-' or c2 == '-':
            status.append('-')
        elif c1 != c2:
            status.append('X')
        else:
            assert False
    a1 = ''.join(a1)
    status = ''.join(status)
    a2 = ''.join(a2)

    a1 = textwrap.wrap(a1, width=width)
    status = textwrap.wrap(status, width=width)
    a2 = textwrap.wrap(a2, width=width)

    for wa1, wst, wa2 in zip(a1, status, a2):
        print(wa1)
        print(wst)
        print(wa2)
        print("")


def __perfect_overlap(s1, s2):
    assert len(s1) >= len(s2)
    if s1 == s2:
        return s1

    longest_overlap = ""
    for i in range(len(s2)+1):
        p1, p2 = s1[:i], s2[-i:]
        if p1 == p2 and len(p1) >= len(longest_overlap):
            longest_overlap = p1
    for i in range(len(s1)-len(s2)+1):
        p1, p2 = s1[i:i+len(s2)], s2
        if p1 == p2 and len(p1) >= len(longest_overlap):
            longest_overlap = p1
    for i in range(len(s2)+1):
        p1, p2 = s1[-i:], s2[:i]
        if p1 == p2 and len(p1) >= len(longest_overlap):
            longest_overlap = p1
    return longest_overlap


def perfect_overlap(s1, s2):
    return __perfect_overlap(s1, s2) if len(s1) >= len(s2) else __perfect_overlap(s2, s1)


# taken from https://stackoverflow.com/a/2894073
def long_substr(data):
    substrs = lambda x: {x[i:i+j] for i in range(len(x)) for j in range(len(x) - i + 1)}
    s = substrs(data[0])
    for val in data[1:]:
        s.intersection_update(substrs(val))
    return max(s, key=len)
