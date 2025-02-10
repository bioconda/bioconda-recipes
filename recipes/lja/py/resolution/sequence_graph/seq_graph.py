# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

from abc import ABC, abstractmethod
from collections import defaultdict, namedtuple
from config.config import config
import logging
import os
import pickle
from subprocess import Popen

import networkx as nx
import numpy as np

from sequence_graph.mapping import find_overlaps, get_chains

from utils.os_utils import smart_makedirs
from utils.various import fst_iterable

logger = logging.getLogger("centroFlye.sequence_graph.sequence_graph")


class SequenceGraph(ABC):
    label = 'label'
    color = 'color'
    edge_index = 'edge_index'
    string = 'string'
    length = 'length'

    def __init__(self,
                 nx_graph=None,
                 nodeindex2label=None,
                 nodelabel2index=None,
                 collapse=True):
        all_None = all((nx_graph is None,
                        nodeindex2label is None,
                        nodelabel2index is None))
        all_notNone = all((nx_graph is not None,
                           nodeindex2label is not None,
                           nodelabel2index is not None))
        assert all_None or all_notNone

        if nx_graph is None:  # and thus all parameters are None
            self.nx_graph = nx.MultiDiGraph()
            self.nodeindex2label = {}
            self.nodelabel2index = {}
            self.edge_index2edge = {}
        else:
            self.nx_graph = nx_graph
            self.nodeindex2label = nodeindex2label
            self.nodelabel2index = nodelabel2index
            self.edge_index2edge = \
                {edge_data[self.edge_index]: (s, e, k)
                for s, e, k, edge_data in nx_graph.edges(keys=True, data=True)}
            self._assert_nx_graph_validity()

        self.db_index = None

        if collapse:
            self.removed_edge_indexes = self.collapse_nonbranching_paths()
        else:
            self.removed_edge_indexes = []


    @classmethod
    def from_pickle(cls, fn):
        with open(fn, 'rb') as f:
            db_graph = pickle.load(f)
        return db_graph

    @classmethod
    @abstractmethod
    def _generate_label(cls, par_dict):
        pass

    @abstractmethod
    def _add_edge(self, color, string,
                  in_node, out_node,
                  in_data, out_data,
                  edge_len,
                  edge_index):
        pass

    def _assert_nx_graph_validity(self):
        for n_ind1, n_ind2, string in self.nx_graph.edges.data(self.string):
            n_label1 = self.nodeindex2label[n_ind1]
            n_label2 = self.nodeindex2label[n_ind2]
            assert string[:len(n_label1)] == n_label1
            assert string[-len(n_label2):] == n_label2
        assert len(self.nx_graph.nodes) == len(self.nodeindex2label)
        assert len(self.nx_graph.nodes) == len(self.nodelabel2index)
        for s, e, k, data in self.nx_graph.edges(keys=True, data=True):
            edge_index = data[self.edge_index]
            assert edge_index in self.edge_index2edge
            assert (s, e, k) == self.edge_index2edge[edge_index]

        edges = set(self.nx_graph.edges(keys=True))
        for edge in self.edge_index2edge.values():
            assert edge in edges

    def collapse_nonbranching_paths(self):
        def node_on_nonbranching_path(node):
            if self.nx_graph.in_degree(node) != 1 or \
               self.nx_graph.out_degree(node) != 1:
                return False

            in_edge = fst_iterable(self.nx_graph.in_edges(node, keys=True))
            out_edge = fst_iterable(self.nx_graph.out_edges(node, keys=True))

            in_edge_color = self.nx_graph.get_edge_data(*in_edge)[self.color]
            out_edge_color = self.nx_graph.get_edge_data(*out_edge)[self.color]

            # if in_edge == out_edge this is a loop and should not be removed
            return in_edge != out_edge and in_edge_color == out_edge_color

        nodes = list(self.nx_graph)
        removed_edge_indexes = []
        for node in nodes:
            if node_on_nonbranching_path(node):
                in_edge = fst_iterable(self.nx_graph.in_edges(node, keys=True))
                out_edge = fst_iterable(self.nx_graph.out_edges(node,
                                                                keys=True))
                in_node, out_node = in_edge[0], out_edge[1]

                in_data = self.nx_graph.get_edge_data(*in_edge)
                out_data = self.nx_graph.get_edge_data(*out_edge)

                in_color = in_data[self.color]
                out_color = out_data[self.color]
                assert in_color == out_color
                color = in_color

                in_string = in_data[self.string]
                out_string = out_data[self.string]
                len_node = len(self.nodeindex2label[node])
                string = in_string + out_string[len_node:]
                string = tuple(string)
                edge_len = len(string) - len_node

                edge_index = in_data[self.edge_index]

                self._add_edge(color=color, string=string,
                               in_node=in_node, out_node=out_node,
                               in_data=in_data, out_data=out_data,
                               edge_len=edge_len,
                               edge_index=edge_index)
                removed_edge_indexes.append(out_data[self.edge_index])

                self.nx_graph.remove_node(node)
                label = self.nodeindex2label[node]
                del self.nodeindex2label[node]
                del self.nodelabel2index[label]
                del self.edge_index2edge[out_data[self.edge_index]]

        self._assert_nx_graph_validity()
        return removed_edge_indexes

    def get_path(self, list_edges, e_st=None, e_en=None,
                 respect_cycled=True):
        assert (e_st is None) == (e_en is None)

        if len(list_edges) == 0:
            return tuple()

        for e1, e2 in zip(list_edges[:-1], list_edges[1:]):
            assert e1[1] == e2[0]

        path = []
        fst_edge = list_edges[0]
        fst_edge_data = self.nx_graph.get_edge_data(*fst_edge)
        path += fst_edge_data[self.string]
        for edge in list_edges[1:]:
            edge_data = self.nx_graph.get_edge_data(*edge)
            edge_string = edge_data[self.string]
            in_node = edge[0]
            len_node = len(self.nodeindex2label[in_node])
            assert tuple(path[-len_node:]) == edge_string[:len_node]
            path += edge_string[len_node:]

        if not respect_cycled:
            return tuple(path)

        # process cycled path
        fst_node = fst_edge[0]
        lst_edge = list_edges[-1]
        lst_node = lst_edge[1]
        if fst_node == lst_node:
            len_node = len(self.nodeindex2label[fst_node])
            path = path[:-len_node]

        if e_st is not None:
            last_edge = list_edges[-1]
            last_edge_data = self.nx_graph.get_edge_data(*last_edge)
            last_edge_string = last_edge_data[self.string]
            last_edge_len = len(last_edge_string)
            if e_en == last_edge_len:
                path = path[e_st:]
            else:
                path = path[e_st:-(last_edge_len-e_en)]

        return tuple(path)

    def index_edges(self):
        if self.db_index is not None:
            return self.db_index
        all_index = {}

        # in case of db this is just min_k == max_k == k
        label_lens = [len(label) for label in self.nodelabel2index.keys()]
        min_k = 1 + min(label_lens)
        max_k = 1 + max(label_lens)
        for k in range(min_k, max_k+1):
            index = defaultdict(list)
            for e_ind, edge in enumerate(self.nx_graph.edges(keys=True)):
                e_data = self.nx_graph.get_edge_data(*edge)
                e_str = e_data[self.string]
                for i in range(len(e_str)-k+1):
                    kmer = e_str[i:i+k]
                    index[kmer].append((e_ind, i))
            index_unique = {kmer: pos[0]
                            for kmer, pos in index.items()
                            if len(pos) == 1}
            all_index[k] = index_unique
        self.db_index = all_index
        return all_index

    def get_contigs(self):
        # this function does not respect color of edges
        def get_longest_valid_outpaths(graph):
            def get_valid_outpath_edge(edge, taken_edges=None):
                if taken_edges is None:
                    taken_edges = set()
                path = [edge]
                out_node = edge[1]
                out_degree_out_node = graph.out_degree(out_node)
                if out_degree_out_node == 1:
                    out_edge = list(
                        graph.out_edges(
                            out_node, keys=True))[0]
                    if out_edge not in taken_edges:
                        taken_edges.add(edge)
                        out_edge_path = \
                            get_valid_outpath_edge(out_edge,
                                                   taken_edges=taken_edges)
                        path += out_edge_path
                return path

            outpaths = {}
            for edge in graph.edges(keys=True):
                if edge not in outpaths:
                    outpaths[edge] = get_valid_outpath_edge(edge)
                    # all outpaths for edges AFTER edge are computed
                    for i, e in enumerate(outpaths[edge][1:]):
                        outpaths[e] = outpaths[edge][i+1:]
            return outpaths

        outpaths = get_longest_valid_outpaths(self.nx_graph)

        rev_graph = self.nx_graph.reverse()
        rev_inpaths = get_longest_valid_outpaths(rev_graph)
        # need to reverse rev_inpaths
        inpaths = {}
        for rev_edge in rev_inpaths:
            edge = (rev_edge[1], rev_edge[0], rev_edge[2])
            inpaths[edge] = rev_inpaths[rev_edge][::-1]
            inpaths[edge] = [(e[1], e[0], e[2]) for e in inpaths[edge]]

        # unite inpaths and outpaths
        valid_paths = []
        for edge in outpaths:
            valid_path = inpaths[edge]
            seen_edges = set(inpaths[edge])
            for e in outpaths[edge][1:]:
                if e not in seen_edges:
                    valid_path.append(e)
                    seen_edges.add(e)
                else:
                    # cycle
                    break
            valid_path = tuple(valid_path)
            valid_paths.append(valid_path)

        valid_paths = list(set(valid_paths))

        # Select only paths that are not a subpath of other paths
        selected_paths = []
        for path1 in valid_paths:
            has_duplicate = False
            for path2 in valid_paths:
                if path1 == path2:
                    continue
                for i in range(len(path2)-len(path1)+1):
                    if path1 == path2[i:i+len(path1)]:
                        has_duplicate = True
                        break
                if has_duplicate:
                    break
            if not has_duplicate:
                selected_paths.append(path1)
        valid_paths = selected_paths

        # convert edge paths into strings
        contigs = []
        for path in valid_paths:
            contigs.append(self.get_path(path))
        contigs = list(set(contigs))
        return contigs, valid_paths

    def map_strings(self, string_set, overlap_penalty, neutral_symbs,
                    only_unique_paths=False,
                    outdir=None,
                    n_threads=config['common']['threads'],
                    min_len=None):

        logger.info('Mapping monostrings to graph')
        logger.info('Computing overlaps')
        if min_len is None:
            logger.info('No min len parameter. All strings will be aligned')
        else:
            logger.info(f'Only strings longer than {min_len} will be aligned')
            total_reads = len(string_set)
            string_set = {s_id: string for s_id, string in string_set.items()
                          if len(string) >= min_len}
            long_reads = len(string_set)
            logger.info(f'{long_reads} / {total_reads} longer than {min_len}')

        overlaps, excessive_overlaps = \
            find_overlaps(graph=self,
                          string_set=string_set,
                          overlap_penalty=overlap_penalty,
                          neutral_symbs=neutral_symbs,
                          n_threads=n_threads)
        # print(overlaps)

        logger.info('Computing chains')
        chains = get_chains(graph=self, overlaps=overlaps, n_threads=n_threads)

        unmapped = {s_id for s_id, s_chains in chains.items()
                    if len(s_chains) == 0}
        logger.info(f'{len(unmapped)} strings are unmapped')
        logger.info(f'That includes {len(excessive_overlaps)} reads '
                    f'with too many overlaps (see config)')

        unique_mapping = {s_id for s_id, s_chains in chains.items()
                          if len(s_chains) == 1}
        logger.info(f'{len(unique_mapping)} strings are uniquely mapped')

        if outdir is not None:
            smart_makedirs(outdir)

            unmapped_fn = os.path.join(outdir, 'unmapped.txt')
            with open(unmapped_fn, 'w') as f:
                for s_id in unmapped:
                    print(s_id, file=f)

            excessive_fn = os.path.join(outdir, 'excessive.txt')
            with open(excessive_fn, 'w') as f:
                print('s_id', '#overlaps', file=f)
                for s_id, s_overlaps in excessive_overlaps.items():
                    print(s_id, len(s_overlaps), file=f)

            chains_fn = os.path.join(outdir, 'chains.txt')
            with open(chains_fn, 'w') as f:
                for s_id, s_chains in chains.items():
                    for chain in s_chains:
                        print(s_id, chain, file=f)

            unique_fn = os.path.join(outdir, 'unique.txt')
            with open(unique_fn, 'w') as f:
                for s_id in unique_mapping:
                    print(s_id, file=f)

        paths = defaultdict(list)
        for r_id, chains_r_id in chains.items():
            for chain in chains_r_id:
                path = [overlap.edge for overlap in chain.overlap_list]
                e_st = chain.overlap_list[0].e_st
                e_en = chain.overlap_list[-1].e_en
                paths[r_id].append((path, e_st, e_en))
        if only_unique_paths:
            paths = {r_id: paths_r_id[0]
                     for r_id, paths_r_id in paths.items()
                     if len(paths_r_id) == 1}
        return paths

    def map_strings_fast(self, strings):
        Mapping = namedtuple('Mapping', ['s_st', 's_en', 'valid', 'epath'])
        index = self.index_edges()
        mappings = {}
        db_edges = list(self.nx_graph.edges(keys=True))

        # for db k == self.k
        k = max(index.keys())
        index = index[k]
        for s_id, string in strings.items():
            str_coords = []
            for i in range(len(string)-k+1):
                kmer = tuple(string[i:i+k])
                if kmer in index:
                    str_coords.append((index[kmer], i))

            if len(str_coords) == 0:
                mappings[s_id] = None
                continue

            (edge_ind, edge_coord), _ = str_coords[0]
            edge_path = [edge_ind]
            for (cur_edge_ind, cur_edge_coord), _ in str_coords[1:]:
                if edge_ind != cur_edge_ind or cur_edge_coord <= edge_coord:
                    edge_path.append(cur_edge_ind)
                edge_ind = cur_edge_ind
                edge_coord = cur_edge_coord
            path = [db_edges[edge_ind] for edge_ind in edge_path]

            valid_path = True
            for e1, e2 in zip(path[:-1], path[1:]):
                if e1[1] != e2[0]:
                    valid_path = False
                    break
            mappings[s_id] = Mapping(str_coords[0], str_coords[-1],
                                     valid_path, path)
        return mappings

    def write_dot(self, outfile, compact=False, export_pdf=True):
        if outfile[-3:] == 'dot':
            outfile = outfile[:-4]
        if not compact:
            graph = self.nx_graph
        else:
            graph = nx.MultiDiGraph()
            for s, e, key, data in self.nx_graph.edges(keys=True, data=True):
                graph.add_edge(s, e, key,
                               color=data[self.color],
                               label=data[self.label])
        dotfile = f'{outfile}.dot'
        nx.drawing.nx_pydot.write_dot(graph, dotfile)
        if export_pdf:
            pdffile = f'{outfile}.pdf'
            # https://stackoverflow.com/a/3516106
            cmd = ['dot', '-Tpdf', dotfile, '-o', pdffile]
            Popen(cmd,
                  shell=False,
                  stdin=None, stdout=None, stderr=None,
                  close_fds=True)

    def pickle_dump(self, fn):
        with open(fn, 'wb') as f:
            pickle.dump(self, f)
