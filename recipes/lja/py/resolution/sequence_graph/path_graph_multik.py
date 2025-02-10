# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

import argparse
from collections import defaultdict
import logging
import math
import os
import subprocess
import sys

this_dirname = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(this_dirname, os.path.pardir))

import networkx as nx

from sequence_graph.path_graph import IDBMappings
from standard_logger import get_logger
from subprocess import call
from utils.bio import read_bio_seqs, read_bio_seq, compress_homopolymer, \
    write_bio_seqs
from utils.git import get_git_revision_short_hash
from utils.os_utils import smart_makedirs, expandpath
from utils.various import fst_iterable


logger = logging.getLogger("centroFlye.sequence_graph.path_graph_multik")


class PathMultiKGraph:
    def __init__(self, nx_graph,
                 edge2seq, edge2index, index2edge, node2len,
                 max_edge_index, max_node_index,
                 idb_mappings,
                 init_k,
                 K,
                 unique_edges=None):
        self.nx_graph = nx_graph
        self.edge2seq = edge2seq
        self.edge2index = edge2index
        self.index2edge = index2edge
        self.node2len = node2len
        self.max_edge_index = max_edge_index
        self.max_node_index = max_node_index
        self.idb_mappings = idb_mappings
        self.init_k = init_k
        self.SATURATING_K = K
        if unique_edges is None:
            unique_edges = set()
        self.unique_edges = unique_edges

        self.niter = 0

        self.unresolved = set()
        self._update_unresolved_vertices()

        self.assert_validity()

    def assert_validity(self):
        if len(self.index2edge) == 0:
            return
        self.max_edge_index == 1 + max(self.index2edge)
        self.max_node_index == 1 + max(self.nx_graph.nodes)
        edges = set(self.nx_graph.edges(keys=True))
        assert edges == set(self.edge2index.keys())
        assert edges == set(self.index2edge.values())
        assert all(edge == self.index2edge[self.edge2index[edge]]
                   for edge in self.edge2index)

        ac = self.idb_mappings.get_active_connections()
        for i, j in ac:
            _, u, _ = self.index2edge[i]
            v, _, _ = self.index2edge[j]
            # print(i, j, self.index2edge[i], self.index2edge[j])
            assert u == v

        for node in self.nx_graph.nodes:
            assert node in self.node2len
            nlen = self.node2len[node]
            if node not in self.unresolved:
                assert self.nx_graph.in_degree(node) != 1 or \
                    self.nx_graph.out_degree(node) != 1

            for in_edge in self.nx_graph.in_edges(node, keys=True):
                e_index = self.edge2index[in_edge]
                in_seq = self.edge2seq[e_index]
                insuf = in_seq[-nlen:]
                for out_edge in self.nx_graph.out_edges(node, keys=True):
                    e_outdex = self.edge2index[out_edge]
                    out_seq = self.edge2seq[e_outdex]
                    outpref = out_seq[:nlen]
                    assert node in self.unresolved or insuf == outpref

    @classmethod
    def fromDB(cls, db, string_set,
               neutral_symbs=None, raw_mappings=None, K=None):
        if raw_mappings is None:
            raw_mappings = db.map_strings(string_set,
                                          only_unique_paths=True,
                                          neutral_symbs=neutral_symbs)

        nx_graph = nx.MultiDiGraph()
        edge2seq = {}
        edge_index = 0
        edge2index = {}
        index2edge = {}
        node2len = {}

        for u in db.nx_graph.nodes():
            node2len[u] = db.k-1

        for u, v, key, data in db.nx_graph.edges(data=True, keys=True):
            nx_graph.add_edge(u, v, key)
            edge2index[(u, v, key)] = edge_index
            index2edge[edge_index] = (u, v, key)
            edge2seq[edge_index] = list(data['string'])
            edge_index += 1

        mappings = {}
        for r_id, (raw_mapping, _, _) in raw_mappings.items():
            mappings[r_id] = [edge2index[edge] for edge in raw_mapping]

        idb_mappings = IDBMappings(mappings)
        max_node_index = 1 + max(nx_graph.nodes)

        return cls(nx_graph=nx_graph,
                   edge2seq=edge2seq,
                   edge2index=edge2index,
                   index2edge=index2edge,
                   node2len=node2len,
                   max_edge_index=edge_index,
                   max_node_index=max_node_index,
                   idb_mappings=idb_mappings,
                   init_k=db.k,
                   K=K)

    @classmethod
    def from_mono_db(cls, db, monostring_set,
                     mappings=None):
        monostring = fst_iterable(monostring_set.values())
        neutral_symbs = set([monostring.gap_symb])
        return cls.fromDB(db=db,
                          string_set=monostring_set,
                          neutral_symbs=neutral_symbs,
                          raw_mappings=mappings)

    @classmethod
    def fromDR(cls, db_fn, align_fn, k, K):
        class PerfectHash:
            hash2index = {}
            next_key = 0

            def __getitem__(self, key):
                if key in self.hash2index:
                    return self.hash2index[key]
                self.hash2index[key] = self.next_key
                self.next_key += 1
                return self.hash2index[key]

        db = read_bio_seqs(db_fn)
        nx_graph = nx.MultiDiGraph()
        edge2seq = {}
        edge2index = {}
        index2edge = {}
        node2len = {}
        ph = PerfectHash()
        max_edge_index = 0
        vertex_nucl2edgeindex = {}
        edge2cov = {}
        for e_id, seq in db.items():
            split_id = e_id.split('_')
            index, s, e, _, cov = split_id
            index, s, e = int(index), int(s), int(e)
            cov = float(cov)
            s = ph[s]
            e = ph[e]
            key = nx_graph.add_edge(s, e)
            edge = (s, e, key)
            edge2seq[index] = list(seq)
            edge2index[edge] = index
            index2edge[index] = edge
            edge2cov[index] = cov
            max_edge_index = max(index, max_edge_index)
            vertex_nucl2edgeindex[(s, seq[k-1])] = index
            node2len[s] = k - 1
            node2len[e] = k - 1

        max_edge_index += 1

        average_cov = sum(edge2cov[index] * len(edge2seq[index])
                          for index in edge2cov) / \
            sum(len(edge2seq[index]) for index in edge2cov)
        logger.info(f'Average coverage {average_cov}')
        unique_edges = set([index for index, cov in edge2cov.items()
                            if cov <= average_cov * 1.2])

        mappings = {}
        with open(align_fn) as f:
            for i, line in enumerate(f):
                s_id, u, nucl = line.strip().split()
                u = ph[int(u)]
                mapping = []
                for c in nucl:
                    e = vertex_nucl2edgeindex[(u, c)]
                    mapping.append(e)
                    u = index2edge[e][1]
                mappings[s_id] = mapping

        idb_mappings = IDBMappings(mappings)

        return cls(nx_graph=nx_graph,
                   edge2seq=edge2seq,
                   edge2index=edge2index,
                   index2edge=index2edge,
                   node2len=node2len,
                   max_edge_index=max_edge_index,
                   max_node_index=ph.next_key,
                   init_k=k,
                   idb_mappings=idb_mappings,
                   unique_edges=unique_edges,
                   K=K)

    def move_edge(self, e1_st, e1_en, e1_key,
                  e2_st, e2_en, e2_key=None):
        old_edge = (e1_st, e1_en, e1_key)
        i = self.edge2index[old_edge]
        self.nx_graph.remove_edge(*old_edge)
        e2_key = self.nx_graph.add_edge(e2_st, e2_en, key=e2_key)
        new_edge = (e2_st, e2_en, e2_key)
        self.edge2index[new_edge] = i
        del self.edge2index[old_edge]
        self.index2edge[i] = new_edge

    def remove_edge(self, edge=None, index=None, moving=True):
        assert (edge is None) != (index is None)
        if edge is None:
            edge = self.index2edge[index]
        else:
            index = self.edge2index[edge]
        self.idb_mappings.remove(index)
        self.nx_graph.remove_edge(*edge)
        del self.edge2index[edge]
        del self.index2edge[index]
        del self.edge2seq[index]

        self.unique_edges.discard(index)

        if moving:
            for e in list(self.nx_graph.in_edges(edge[1], keys=True)):
                self.move_edge(*e, e[0], edge[0])

            for e in list(self.nx_graph.out_edges(edge[1], keys=True)):
                self.move_edge(*e, edge[0], e[1])

    def get_new_vertex_index(self):
        index = self.max_node_index
        self.node2len[index] = self.init_k - 1 + self.niter
        self.max_node_index += 1
        return index

    def merge_edges(self, e1, e2):
        assert self.nx_graph.degree(e1[1]) == 1
        assert self.nx_graph.degree(e2[0]) == 1
        i = self.edge2index[e1]
        j = self.edge2index[e2]
        self.idb_mappings.merge(i, j)
        if j in self.unique_edges:
            self.unique_edges.add(i)
        in_seq = self.edge2seq[i]
        out_seq = self.edge2seq[j]
        nlen = self.node2len[e2[0]]-1  # need -1 since new nodes have ++
        assert in_seq[-nlen:] == out_seq[:nlen]
        seq = in_seq + out_seq[nlen:]
        self.edge2seq[i] = seq
        self.move_edge(*e1, e1[0], e2[1])
        self.remove_edge(edge=e2, moving=False)

    def add_edge(self, i, j, seq):
        in_edge = self.index2edge[i]
        out_edge = self.index2edge[j]
        new_edge = (in_edge[1], out_edge[0])
        key = self.nx_graph.add_edge(*new_edge)
        new_edge = (*new_edge, key)
        self.edge2index[new_edge] = self.max_edge_index
        self.index2edge[self.max_edge_index] = new_edge
        self.edge2seq[self.max_edge_index] = seq
        self.idb_mappings.add(i, j, self.max_edge_index)
        self.max_edge_index += 1

    def _update_unresolved_vertices(self):
        for u in self.nx_graph.nodes:
            if u in self.unresolved:
                continue
            in_indexes = set(
                [self.edge2index[e_in]
                 for e_in in self.nx_graph.in_edges(u, keys=True)])
            out_indexes = set(
                [self.edge2index[e_out]
                 for e_out in self.nx_graph.out_edges(u, keys=True)])
            indegree = self.nx_graph.in_degree(u)
            outdegree = self.nx_graph.out_degree(u)
            if indegree == 1 and outdegree == 1:
                self_loop = in_indexes == out_indexes
                # assert self_loop
                self.unresolved.add(u)
            elif indegree >= 2 and outdegree >= 2:
                # do not process anything at all
                # self.unresolved.add(u)

                # process only fully resolved vertices
                # all_ac = self.idb_mappings.get_active_connections()
                # pairs = set()
                # for e_in in in_indexes:
                #     for e_out in out_indexes:
                #         if (e_in, e_out) in all_ac:
                #             pairs.add((e_in, e_out))
                # all_pairs = set((e_in, e_out)
                #                 for e_in in in_indexes
                #                 for e_out in out_indexes)
                # if len(all_pairs - pairs):
                #     self.unresolved.add(u)

                # initial heuristic
                paired_in = set()
                paired_out = set()
                loops = in_indexes & out_indexes
                if len(loops) == 1:
                    loop = fst_iterable(loops)
                    if loop in self.unique_edges:
                        rest_in = in_indexes - loops
                        rest_out = out_indexes - loops
                        if len(rest_in) == 1:
                            in_index = fst_iterable(rest_in)
                            paired_in.add(in_index)
                            paired_out.add(loop)
                        if len(rest_out) == 1:
                            out_index = fst_iterable(rest_out)
                            paired_in.add(loop)
                            paired_out.add(out_index)

                for e_in in in_indexes:
                    for e_out in out_indexes:
                        if (e_in, e_out) in self.idb_mappings.pairindex2pos:
                            paired_in.add(e_in)
                            paired_out.add(e_out)

                unpaired_in = set(in_indexes) - paired_in
                unpaired_out = set(out_indexes) - paired_out
                if len(unpaired_in) == 1 and len(unpaired_out) == 1:
                    if len(set(in_indexes) - self.unique_edges) == 0 or \
                            len(set(out_indexes) - self.unique_edges) == 0:
                        unpaired_in_single = list(unpaired_in)[0]
                        unpaired_out_single = list(unpaired_out)[0]
                        paired_in.add(unpaired_in_single)
                        paired_out.add(unpaired_out_single)

                tips = (in_indexes - paired_in) | (out_indexes - paired_out)

                if len(tips):
                    self.unresolved.add(u)

        prev, new = self.unresolved, set()
        while len(prev):
            for u in prev:
                for edge in self.nx_graph.in_edges(u, keys=True):
                    index = self.edge2index[edge]
                    seq = self.edge2seq[index]
                    v = edge[0]
                    if v in self.unresolved:
                        continue
                    if self.node2len[v] + 1 == len(seq):
                        new.add(v)
                for edge in self.nx_graph.out_edges(u, keys=True):
                    index = self.edge2index[edge]
                    seq = self.edge2seq[index]
                    v = edge[1]
                    if v in self.unresolved:
                        continue
                    if self.node2len[v] + 1 == len(seq):
                        new.add(v)
            self.unresolved |= new
            prev, new = new, set()

    def __process_vertex(self, u):
        def process_simple():
            if indegree == 1 and outdegree == 1:
                # node on nonbranching path - should not be happening
                assert False

            if indegree == 0 and outdegree == 0:
                # isolate - should be removed
                self.nx_graph.remove_node(u)
                del self.node2len[u]
                return

            elif indegree == 0 and outdegree > 0:
                # starting vertex
                for j in out_indexes[1:]:
                    old_edge = self.index2edge[j]
                    new_edge = (self.get_new_vertex_index(), old_edge[1], 0)
                    self.move_edge(*old_edge, *new_edge)

            elif indegree > 0 and outdegree == 0:
                # ending vertex
                for i in in_indexes[1:]:
                    old_edge = self.index2edge[i]
                    new_edge = (old_edge[0], self.get_new_vertex_index(), 0)
                    self.move_edge(*old_edge, *new_edge)

            elif indegree == 1 and outdegree > 1:
                # simple 1-in vertex
                assert len(in_indexes) == 1
                in_index = in_indexes[0]
                in_seq = self.edge2seq[in_index]
                c = in_seq[-nlen-1]
                for j in out_indexes:
                    assert self.edge2seq[j][:nlen] == in_seq[-nlen:]
                    self.edge2seq[j].insert(0, c)

            elif indegree > 1 and outdegree == 1:
                # simple 1-out vertex
                assert len(out_indexes) == 1
                out_index = out_indexes[0]
                out_seq = self.edge2seq[out_index]
                c = out_seq[nlen]
                for i in in_indexes:
                    assert self.edge2seq[i][-nlen:] == out_seq[:nlen]
                    self.edge2seq[i].append(c)
            self.node2len[u] += 1

        def process_complex():
            # complex vertex
            for i in in_indexes:
                old_edge = self.index2edge[i]
                new_edge = (old_edge[0], self.get_new_vertex_index(), 0)
                self.move_edge(*old_edge, *new_edge)

            for j in out_indexes:
                old_edge = self.index2edge[j]
                new_edge = (self.get_new_vertex_index(), old_edge[1], 0)
                self.move_edge(*old_edge, *new_edge)

            ac_s2e = defaultdict(set)
            ac_e2s = defaultdict(set)
            paired_in = set()
            paired_out = set()
            for e_in in in_indexes:
                for e_out in out_indexes:
                    if (e_in, e_out) in self.idb_mappings.pairindex2pos:
                        ac_s2e[e_in].add(e_out)
                        ac_e2s[e_out].add(e_in)
                        paired_in.add(e_in)
                        paired_out.add(e_out)

            loops = set(in_indexes) & set(out_indexes)
            if len(loops) == 1:
                loop = fst_iterable(loops)
                if loop in self.unique_edges:
                    rest_in = set(in_indexes) - loops
                    rest_out = set(out_indexes) - loops
                    if len(rest_in) == 1:
                        in_index = fst_iterable(rest_in)
                        ac_s2e[in_index].add(loop)
                        ac_e2s[loop].add(in_index)
                    if len(rest_out) == 1:
                        out_index = fst_iterable(rest_out)
                        ac_s2e[loop].add(out_index)
                        ac_e2s[out_index].add(loop)

            unpaired_in = set(in_indexes) - paired_in
            unpaired_out = set(out_indexes) - paired_out
            if len(unpaired_in) == 1 and len(unpaired_out) == 1:
                if len(set(in_indexes) - self.unique_edges) == 0 or \
                        len(set(out_indexes) - self.unique_edges) == 0:
                    unpaired_in_single = list(unpaired_in)[0]
                    unpaired_out_single = list(unpaired_out)[0]
                    ac_s2e[unpaired_in_single].add(unpaired_out_single)
                    ac_e2s[unpaired_out_single].add(unpaired_in_single)

            # print(u, ac_s2e, ac_e2s)
            merged = {}
            for i in ac_s2e:
                for j in ac_s2e[i]:
                    # print(u, i, j, ac_s2e[i], ac_e2s[j])
                    if i in merged:
                        i = merged[i]
                    if j in merged:
                        j = merged[j]
                    e_i = self.index2edge[i]
                    e_j = self.index2edge[j]
                    in_seq = self.edge2seq[i]
                    out_seq = self.edge2seq[j]
                    assert in_seq[-nlen:] == out_seq[:nlen]
                    if len(ac_s2e[i]) == len(ac_e2s[j]) == 1:
                        if e_i != e_j:
                            self.merge_edges(e_i, e_j)
                            merged[j] = i
                        else:
                            # isolated loop
                            self.move_edge(*e_i, e_i[0], e_i[0])
                            if in_seq[-nlen-1:] != in_seq[:nlen+1]:
                                self.edge2seq[i].append(in_seq[nlen])
                    elif len(ac_s2e[i]) >= 2 and len(ac_e2s[j]) >= 2:
                        seq = in_seq[-nlen-1:] + [out_seq[nlen]]
                        assert len(seq) == nlen + 2
                        self.add_edge(i, j, seq)
                    elif len(ac_s2e[i]) == 1 and len(ac_e2s[j]) >= 2:
                        # extend left edge to the right
                        self.move_edge(*e_i, e_i[0], e_j[0])
                        seq = in_seq + [out_seq[nlen]]
                        self.edge2seq[i] = seq
                    elif len(ac_e2s[j]) == 1 and len(ac_s2e[i]) >= 2:
                        # extend right edge to the left
                        self.move_edge(*e_j, e_i[1], e_j[1])
                        seq = [in_seq[-nlen-1]] + out_seq
                        self.edge2seq[j] = seq
                    else:
                        assert False

            assert self.nx_graph.in_degree(u) == 0
            assert self.nx_graph.out_degree(u) == 0
            self.nx_graph.remove_node(u)
            del self.node2len[u]

        in_indexes = [self.edge2index[e_in]
                      for e_in in self.nx_graph.in_edges(u, keys=True)]
        out_indexes = [self.edge2index[e_out]
                       for e_out in self.nx_graph.out_edges(u, keys=True)]

        indegree = self.nx_graph.in_degree(u)
        outdegree = self.nx_graph.out_degree(u)

        nlen = self.node2len[u]

        if indegree >= 2 and outdegree >= 2:
            process_complex()
        else:
            process_simple()

    def transform_single(self):
        if self.unresolved == set(self.nx_graph.nodes):
            return True

        self.niter += 1
        for u in list(self.nx_graph.nodes):
            if u not in self.unresolved:
                self.__process_vertex(u)
        self.finalize_transformation()
        return False

    def transform(self, N):
        for _ in range(N):
            self.transform_single()

    def transform_until_saturated(self):
        while not self.transform_single():
            pass

    def get_niter_wo_complex(self):
        n_iter_wo_complex = math.inf
        for u in list(self.nx_graph.nodes):
            if u in self.unresolved:
                continue
            indegree = self.nx_graph.in_degree(u)
            outdegree = self.nx_graph.out_degree(u)
            if (indegree >= 2 and outdegree >= 2) or \
                    (indegree == 0 and outdegree >= 2) or \
                    (indegree >= 2 and outdegree == 0):
                n_iter_wo_complex = 0
                break
            nlen = self.node2len[u]
            in_indexes = [self.edge2index[e_in]
                          for e_in in self.nx_graph.in_edges(u, keys=True)]
            out_indexes = [self.edge2index[e_out]
                           for e_out in self.nx_graph.out_edges(u, keys=True)]
            if indegree == 1:
                index = in_indexes[0]
                fin_node = self.index2edge[index][0]
            elif outdegree == 1:
                index = out_indexes[0]
                fin_node = self.index2edge[index][1]
            else:
                assert False
            seq = self.edge2seq[index]
            n_iter_node = len(seq) - nlen
            if fin_node in self.unresolved:
                n_iter_node -= 1
            n_iter_wo_complex = min(n_iter_wo_complex, n_iter_node)
        n_iter_wo_complex = min(n_iter_wo_complex,
                                self.SATURATING_K - self.init_k - self.niter)
        # k + n + N == K => N = K - k - n
        return n_iter_wo_complex

    def _transform_simple_N(self, N):
        if N == 0:
            return
        for u in list(self.nx_graph.nodes):
            if u in self.unresolved:
                continue
            in_indexes = [self.edge2index[e_in]
                          for e_in in self.nx_graph.in_edges(u, keys=True)]
            out_indexes = [self.edge2index[e_out]
                           for e_out in self.nx_graph.out_edges(u, keys=True)]

            indegree = self.nx_graph.in_degree(u)
            outdegree = self.nx_graph.out_degree(u)
            nlen = self.node2len[u]
            if indegree == 0 and outdegree == 1:
                pass
            elif indegree == 1 and outdegree == 0:
                pass
            elif indegree == 1 and outdegree > 1:
                # simple 1-in vertex
                assert len(in_indexes) == 1
                in_index = in_indexes[0]
                in_seq = self.edge2seq[in_index]
                prefix = in_seq[-nlen-N:-nlen]
                for j in out_indexes:
                    assert self.edge2seq[j][:nlen] == in_seq[-nlen:]
                    self.edge2seq[j] = prefix + self.edge2seq[j]

            elif indegree > 1 and outdegree == 1:
                # simple 1-out vertex
                assert len(out_indexes) == 1
                out_index = out_indexes[0]
                out_seq = self.edge2seq[out_index]
                suffix = out_seq[nlen:nlen+N]
                for i in in_indexes:
                    assert self.edge2seq[i][-nlen:] == out_seq[:nlen]
                    self.edge2seq[i] += suffix
            else:
                assert False
            self.node2len[u] += N
        self.niter += N
        self.finalize_transformation()

    def finalize_transformation(self):
        collapsed_edges = []
        for edge in self.nx_graph.edges:
            index = self.edge2index[edge]
            seq = self.edge2seq[index]
            u, v, _ = edge
            if len(seq) == self.node2len[u] or len(seq) == self.node2len[v]:
                assert self.node2len[u] == self.node2len[v]
                assert u not in self.unresolved and v not in self.unresolved
                collapsed_edges.append(index)
        # remove collapsed edges
        [self.remove_edge(index=index) for index in collapsed_edges]
        self.nx_graph.remove_nodes_from(list(nx.isolates(self.nx_graph)))
        self._update_unresolved_vertices()
        self.assert_validity()

    def transform_single_fast(self):
        if self.unresolved == set(self.nx_graph.nodes):
            return True

        n_iter_wo_complex = self.get_niter_wo_complex()
        logger.info(f'iter={self.niter}, simple_iter={n_iter_wo_complex}, V = {nx.number_of_nodes(self.nx_graph)}, E = {nx.number_of_edges(self.nx_graph)}')

        if n_iter_wo_complex > 0:
            self._transform_simple_N(N=n_iter_wo_complex)
        else:
            self.transform_single()
        return False

    def transform_fast_until_saturated(self):
        while self.init_k + self.niter < self.SATURATING_K and \
                not self.transform_single_fast():
            pass
        self.assert_validity()
        K = self.init_k+self.niter
        logger.info(f'Graph saturated, niter={self.niter}, K={K}')

    def estimate_lower_mult(self):
        mult = {edge: 1 for edge in self.index2edge}
        changed = True
        while changed:
            changed = False
            for u in self.nx_graph.nodes():
                in_indexes = \
                    [self.edge2index[e_in]
                     for e_in in self.nx_graph.in_edges(u, keys=True)]
                out_indexes = \
                    [self.edge2index[e_out]
                     for e_out in self.nx_graph.out_edges(u, keys=True)]
                indegree = self.nx_graph.in_degree(u)
                outdegree = self.nx_graph.out_degree(u)

                in_mult = sum(mult[edge] for edge in in_indexes)
                out_mult = sum(mult[edge] for edge in out_indexes)
                if indegree == 1 and in_mult < out_mult:
                    mult[in_indexes[0]] = out_mult
                    changed = True
                elif outdegree == 1 and out_mult < in_mult:
                    mult[out_indexes[0]] = in_mult
                    changed = True
        return mult

    def write_dot(self, outdir, reffn=None, refhpc=False,
                  compact=False, export_pdf=True):
        if reffn is not None:
            # TODO make a parameter
            exact_matcher_bin = '/Poppy/abzikadze/DR/bin/exact_matcher'
            ref = read_bio_seq(reffn)
            if refhpc:
                ref = compress_homopolymer(ref)
            reffn_outfn = os.path.join(outdir, 'ref.fasta')
            write_bio_seqs(reffn_outfn, {'ref': ref})
            exact_matcher_outfn = os.path.join(outdir, 'edge_matching.tsv')
            edges_fn = os.path.join(
                outdir, f'dbg_{self.init_k}-{self.init_k+self.niter}.fasta')
            exact_matcher_cmd = \
                f'{exact_matcher_bin} --output {exact_matcher_outfn} ' \
                f'--reference {reffn_outfn} --query {edges_fn}'
            logger.info(f'Running exact matcher. Cmd: {exact_matcher_cmd}')
            exact_matcher_cmd = exact_matcher_cmd.split(' ')

            subprocess.call(exact_matcher_cmd)

            mult = defaultdict(lambda: [0, 0])
            with open(exact_matcher_outfn) as f:
                f.readline()
                for line in f:
                    line = line.strip().split('\t')
                    _, index, pos, strand = line
                    index, pos = int(index), int(pos)
                    strand = strand != '+'  # strand == '-' => 0
                    mult[index][strand] += 1

        outfile = os.path.join(outdir,
                               f'dbg_{self.init_k}-{self.init_k+self.niter}')
        graph = nx.MultiDiGraph()
        for node in self.nx_graph.nodes():
            graph.add_node(node, label=f'{node} len={self.node2len[node]}')
        for edge in self.nx_graph.edges(keys=True):
            index = self.edge2index[edge]
            seq = self.edge2seq[index] if not compact else None
            seqlen = len(self.edge2seq[index])
            label = f'index={index}\nlen={seqlen}'
            if reffn is not None:
                # print(mult[index], mult_est[index])
                # assert mult[index] == 0 or mult[index] >= mult_est[index]
                if mult[index] == [0, 0]:
                    logger.info(f'Warning: edge {index} has [0, 0] coverage')
                label += f'\nmult_real={mult[index]}'
            graph.add_edge(*edge,
                           label=label,
                           seq=seq)
        dotfile = f'{outfile}.dot'
        nx.drawing.nx_pydot.write_dot(graph, dotfile)
        if export_pdf and self.nx_graph.size() < 500:
            pdffile = f'{outfile}.pdf'
            # https://stackoverflow.com/a/3516106
            cmd = ['dot', '-Tpdf', dotfile, '-o', pdffile]
            call(cmd)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--dbg", required=True,
                        help="Directory with DBG output")
    parser.add_argument("-o", "--outdir", required=True)
    parser.add_argument("--ref")
    parser.add_argument("--refhpc", action='store_true')
    parser.add_argument("--no_export_pdf", action='store_true')
    parser.add_argument("-K", type=int, default=40002)
    params = parser.parse_args()

    params.dbg = expandpath(params.dbg)
    params.outdir = expandpath(params.outdir)
    smart_makedirs(params.outdir)
    logfn = os.path.join(params.outdir, 'inc_k.log')
    global logger
    logger = get_logger(logfn,
                        logger_name='centroFlye: inc_k')
    logger.info(f'cmd: {sys.argv}')
    logger.info(f'git hash: {get_git_revision_short_hash()}')

    db_fn = os.path.join(params.dbg, 'graph.fasta')
    align_fn = os.path.join(params.dbg, 'alignments.txt')
    dbg_log_fn = os.path.join(params.dbg, 'dbg.log')
    with open(dbg_log_fn) as f:
        cmd = f.readline().strip().split(' ')
        i = 0
        while cmd[i] != '-k':
            i += 1
        k = int(cmd[i+1]) + 1
    logger.info(f'init k = {k}')
    logger.info(f'Reading DBG output from {params.dbg}')
    lpdb = PathMultiKGraph.fromDR(db_fn=db_fn, align_fn=align_fn,
                                  k=k, K=params.K)
    logger.info(f'# vertices = {nx.number_of_nodes(lpdb.nx_graph)}')
    logger.info(f'# edges = {nx.number_of_edges(lpdb.nx_graph)}')
    logger.info(f'Finished reading DBG output')
    logger.info(f'Starting increasing k')
    lpdb.transform_fast_until_saturated()
    logger.info(f'Finished increasing k')
    logger.info(f'# vertices = {nx.number_of_nodes(lpdb.nx_graph)}')
    logger.info(f'# edges = {nx.number_of_edges(lpdb.nx_graph)}')

    outac = os.path.join(params.outdir, f'active_connections.txt')
    logger.info(f'Active connections output to {outac}')
    with open(outac, 'w') as f:
        ac = lpdb.idb_mappings.get_active_connections()
        ac = sorted(list(ac))
        for i, j in ac:
            print(f'{i} {j}', file=f)

    outuniquedges = os.path.join(params.outdir, f'unique_edges.txt')
    logger.info(f'Unique edges output to {outuniquedges}')
    with open(outuniquedges, 'w') as f:
        for index in sorted(list(lpdb.unique_edges)):
            print(index, file=f)

    outdot = os.path.join(params.outdir, f'dbg_{k}-{lpdb.init_k+lpdb.niter}')
    logger.info(f'Writing final graph to {outdot}')

    outfasta = outdot + '.fasta'
    logger.info(f'Writing graph edges to {outfasta}')
    edges = {key: ''.join(edge) for key, edge in lpdb.edge2seq.items()}
    write_bio_seqs(outfasta, edges)

    lpdb.write_dot(params.outdir, compact=True,
                   reffn=params.ref, refhpc=params.refhpc, export_pdf=not params.no_export_pdf)
    logger.info(f'Finished writing final graph (dot)')
    out = open(outdot + ".graph", "w")
    for edge in lpdb.nx_graph.edges(keys=True):
        index = lpdb.edge2index[edge]
        seq = lpdb.edge2seq[index]
        out.write(">" + "_".join([str(index), str(edge[0]), str(lpdb.node2len[edge[0]]), str(edge[1]), str(lpdb.node2len[edge[1]])]) + "\n")
        out.write("".join(seq))
        out.write("\n")
    out.close()



if __name__ == "__main__":
    main()
