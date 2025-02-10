# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

from collections import namedtuple
from config.config import config
import logging

import edlib
from joblib import Parallel, delayed

from utils.various import fst_iterable, chunks_dict

logger = logging.getLogger("centroFlye.sequence_graph.mapping")

Overlap = namedtuple('Overlap', ['edge',
                                 's_st', 's_en',
                                 'e_st', 'e_en'])

Chain = namedtuple('Chain', ['overlap_list', 'length'])


def _find_string_overlaps(string,
                          neutral_symbs,
                          overlap_penalty,
                          edges,
                          addEq):
    monolen = len(string)
    neutral_symb = fst_iterable(neutral_symbs)
    neutral_run_len = max(0, monolen - overlap_penalty)
    neutral_run = neutral_symb * neutral_run_len
    neutral_run = tuple(neutral_run)
    overlaps = []
    for edge, edge_string in edges.items():
        ext_edge_string = neutral_run + edge_string + neutral_run
        align = edlib.align(string,
                            ext_edge_string,
                            mode='HW',
                            k=0,
                            task='locations',
                            additionalEqualities=addEq)
        locations = align['locations']
        for e_st, e_en in locations:
            e_en += 1  # [e_s; e_e)
            assert e_en - e_st == monolen

            # 0123456789
            # --read----
            # ???edge??? => e_s, e_e = [2, 6)
            # left_hanging = max(0, 3-2) = 1
            # right_hanging = max(0, 6-3-4) = 0
            # s_s = left_hanging = 1
            # s_e = 4-right_hanging = 4-0 = 4
            # e_s = max(0, 2-3) = 0
            # e_e = 6-3-0=3

            # 0123456789
            # ----read--
            # ???edge??? => e_s, e_e = [4, 8)
            # left_hanging = max(0, 3-4) = 0
            # right_hanging = max(0, 8-3-4) = 1
            # s_s = 0
            # s_e = 4-1 = 3
            # e_s = max(0, 4-3) = 1
            # e_e = 8-3-1=4

            left_hanging = max(0, neutral_run_len-e_st)
            right_hanging = \
                max(0, e_en-neutral_run_len-len(edge_string))
            s_st, s_en = left_hanging, monolen - right_hanging
            e_st = max(0, e_st-neutral_run_len)
            e_en = e_en - neutral_run_len - right_hanging
            assert e_en == e_st + s_en - s_st
            assert 0 <= e_st < e_en <= len(edge_string)
            assert 0 <= s_st < s_en <= monolen
            for c1, c2 in zip(string[s_st:s_en],
                              edge_string[e_st:e_en]):
                if c1 != c2:
                    assert c1 in neutral_symbs or \
                        c2 in neutral_symbs
            overlap = Overlap(edge=edge,
                              s_st=s_st, s_en=s_en,
                              e_st=e_st, e_en=e_en)
            overlaps.append(overlap)
    overlaps.sort(key=lambda overlap: overlap.s_en)
    return overlaps


def _find_strings_chunk_overlaps(strings_chunk,
                                 neutral_symbs,
                                 overlap_penalty,
                                 edges,
                                 addEq,
                                 max_n_overlaps=config['mapping']['max_n_overlaps']):
    overlaps = {}
    excessive_overlaps = {}
    for s_id, string in strings_chunk.items():
        s_overlaps = _find_string_overlaps(string=string,
                                           neutral_symbs=neutral_symbs,
                                           overlap_penalty=overlap_penalty,
                                           edges=edges,
                                           addEq=addEq)
        if len(s_overlaps) > max_n_overlaps:
            excessive_overlaps[s_id] = s_overlaps
        else:
            overlaps[s_id] = s_overlaps
    return overlaps, excessive_overlaps


def find_overlaps(graph, string_set, overlap_penalty, neutral_symbs,
                  n_threads=config['common']['threads'],
                  max_n_overlaps=config['mapping']['max_n_overlaps']):

    if len(neutral_symbs) == 0:
        neutral_symbs = set(['?'])

    alphabet = set()
    for string in string_set.values():
        alphabet |= set(string)
    addEq = []
    for neutral_symb in neutral_symbs:
        addEq += [(neutral_symb, c) for c in alphabet]
    logger.info(f'Additional equalities = {addEq}')

    edges = {}
    for edge in graph.nx_graph.edges:
        edge_data = graph.nx_graph.get_edge_data(*edge)
        edges[edge] = edge_data['string']

    chunk_size = int(len(string_set) / n_threads) + 1
    strings_chunks = chunks_dict(string_set,
                                 n=chunk_size)
    overlaps_chunks = Parallel(
        n_jobs=n_threads, verbose=50, backend='multiprocessing')(
        delayed(_find_strings_chunk_overlaps)(strings_chunk=strings_chunk,
                                              neutral_symbs=neutral_symbs,
                                              overlap_penalty=overlap_penalty,
                                              edges=edges,
                                              addEq=addEq,
                                              max_n_overlaps=max_n_overlaps)
            for strings_chunk in strings_chunks
        )
    overlaps = {}
    excessive_overlaps = {}
    for overlaps_chunk, excessive_overlaps_chunk in overlaps_chunks:
        overlaps.update(overlaps_chunk)
        excessive_overlaps.update(excessive_overlaps_chunk)
    return overlaps, excessive_overlaps


def _get_string_chains(nodeindex2label, string_overlaps):
    chains = []
    for overlap in string_overlaps:
        overlap_len = overlap.e_en - overlap.e_st
        best_length = overlap_len
        best_chains = [Chain(overlap_list=[overlap],
                             length=best_length)]
        v2, w, _ = overlap.edge
        for chain in chains:
            last_overlap = chain.overlap_list[-1]

            u, v1, _ = last_overlap.edge
            if v1 != v2:
                continue

            v = v1
            v_label = nodeindex2label[v]
            v_len = len(v_label)  # for de Bruijn graph v_len == k

            if last_overlap.s_en - v_len + overlap_len != overlap.s_en:
                continue

            new_length = chain.length - v_len + overlap_len
            new_overlap_list = chain.overlap_list.copy()
            new_overlap_list.append(overlap)
            new_chain = Chain(overlap_list=new_overlap_list,
                              length=new_length)
            if new_length > best_length:
                best_length = new_length
                best_chains = [new_chain]
            elif new_length == best_length:
                best_chains.append(new_chain)
        chains += best_chains

    chains.sort(key=lambda chain: chain.length,
                reverse=True)
    accepted_chains = []
    for chain in chains:
        ch_st = chain.overlap_list[0].s_st
        ch_en = chain.overlap_list[-1].s_en
        overlaps_with_longer = False
        for accepted_chain in accepted_chains:
            if accepted_chain.length == chain.length:
                continue
            a_ch_st = accepted_chain.overlap_list[0].s_st
            a_ch_en = accepted_chain.overlap_list[-1].s_en
            if ch_st <= a_ch_st < ch_en or \
                    ch_st < a_ch_en <= ch_en:
                overlaps_with_longer = True
                break
        if not overlaps_with_longer:
            accepted_chains.append(chain)
    return accepted_chains


def _get_strings_chunk_chains(nodeindex2label,
                              overlaps_chunk):
    chains = {}
    for s_id, overlaps in overlaps_chunk.items():
        chains[s_id] = _get_string_chains(nodeindex2label=nodeindex2label,
                                          string_overlaps=overlaps)
    return chains


def get_chains(graph, overlaps, n_threads=config['common']['threads']):
    chunk_size = int(len(overlaps) / n_threads) + 1
    overlaps_chunks = chunks_dict(overlaps,
                                  n=chunk_size)
    nodeindex2label = graph.nodeindex2label
    chains_chunks = Parallel(
        n_jobs=n_threads, verbose=50, backend='multiprocessing')(
        delayed(_get_strings_chunk_chains)(nodeindex2label=nodeindex2label,
                                           overlaps_chunk=overlaps_chunk)
            for overlaps_chunk in overlaps_chunks
        )
    chains = {}
    for chains_chunk in chains_chunks:
        chains.update(chains_chunk)
    return chains
