# (c) 2019 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

from bisect import bisect_left
from itertools import islice

import numpy as np


def dict_map(f, d):
    return {k: f(v) for k, v in d.items()}


def dict_map_name(f, d):
    return {k: f(k, v) for k, v in d.items()}


def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]

def chunks_dict(data, n):
    data_items = list(data.items())
    for i in range(0, len(data), n):
        yield dict(data_items[i:i+n])

def take_closest(myList, myNumber):
    """
    Assumes myList is sorted. Returns closest value to myNumber.

    If two numbers are equally close, return the smallest number.
    """
    pos = bisect_left(myList, myNumber)
    if pos == 0:
        return 0, myList[0]
    if pos == len(myList):
        return len(myList)-1, myList[-1]
    before = myList[pos - 1]
    after = myList[pos]
    if after - myNumber < myNumber - before:
        return pos, after
    else:
        return pos-1, before


# Taken from https://stackoverflow.com/a/4665027
def find_all_nonoverlap(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1:
            return
        yield start
        start += len(sub)  # use start += 1 to find overlapping matches


def find_all_overlap(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1:
            return
        yield start
        start += 1  # use start += 1 to find overlapping matches


# Taken from https://stackoverflow.com/a/52177077
def chunks2(seq, num):
    avg = len(seq) / float(num)
    out = []
    last = 0.0

    while last < len(seq):
        out.append(seq[int(last):int(last + avg)])
        last += avg

    return out


def get_kmers(fn):
    kmers = []
    with open(fn) as f:
        for line in f:
            kmers.append(line.strip())
    return set(kmers)


def list2str(lst, sep=' '):
    return sep.join(str(e) for e in lst)


def listEls2str(lst):
    return [str(e) for e in lst]


# from https://stackoverflow.com/a/40927266
def weighted_random_by_dct(dct):
    rand_val = np.random.random()
    total = 0
    for k, v in dct.items():
        total += v
        if rand_val <= total:
            return k
    assert False, 'unreachable'

def fst_iterable(iterable):
    return next(iter(iterable))


def index(lst, sublst):
    # search sublst locations in lst (exact match)
    lst = tuple(lst)
    sublst = tuple(sublst)
    locations = []
    for i in range(len(lst)-len(sublst)+1):
        if lst[i:i+len(sublst)] == sublst:
            locations.append((i, i+len(sublst)))
    return locations


def filter_sublsts_n2_dict(dct):
    # filter substrings from a list (dict) of strings
    # Quadratic solution. Better solution uses Suffix Arrays
    res = {}
    for k, v in dct.items():
        if not any(k != t and v != w and len(index(w, v))
                   for t, w in dct.items()):
            res[k] = v
    return res


def running_mean(data, window_size):
    cumsum = np.cumsum(np.insert(data, 0, 0))
    return (cumsum[window_size:] - cumsum[:-window_size]) / window_size
