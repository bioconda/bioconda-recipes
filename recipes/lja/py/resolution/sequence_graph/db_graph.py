# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

import logging

from collections import defaultdict, Counter
from config.config import config

import networkx as nx
import numpy as np

from sequence_graph.seq_graph import SequenceGraph


logger = logging.getLogger("centroFlye.sequence_graph.db_graph")


class DeBruijnGraph(SequenceGraph):
    coverage = 'coverage'

    def __init__(self, nx_graph, nodeindex2label, nodelabel2index, k,
                 collapse=True):
        super().__init__(nx_graph=nx_graph,
                         nodeindex2label=nodeindex2label,
                         nodelabel2index=nodelabel2index,
                         collapse=collapse)
        self.k = k  # length of an edge in the uncompressed graph

    @classmethod
    def _generate_label(cls, par_dict):
        cov = par_dict[cls.coverage]
        length = par_dict[cls.length]
        edge_index = par_dict[cls.edge_index]

        mean_cov = np.mean(cov)
        label = f'index={edge_index}\nlen={length}\ncov={mean_cov:0.2f}'
        return label

    def _add_edge(self, color, string,
                  in_node, out_node,
                  in_data, out_data,
                  edge_len,
                  edge_index):
        in_cov = in_data[self.coverage]
        out_cov = out_data[self.coverage]
        cov = sorted(in_cov + out_cov)
        assert len(cov) == edge_len
        label = self._generate_label({self.length: edge_len,
                                      self.coverage: np.mean(cov),
                                      self.edge_index: edge_index})
        key = self.nx_graph.add_edge(in_node, out_node,
                                     string=string,
                                     coverage=cov,
                                     label=label,
                                     length=edge_len,
                                     color=color,
                                     edge_index=edge_index)
        self.edge_index2edge[edge_index] = (in_node, out_node, key)

    @classmethod
    def from_kmers(cls, kmers, kmer_coverages=None,
                   min_tip_cov=1, collapse=True):
        def add_kmer(kmer, edge_index, coverage=1, color='black'):
            prefix, suffix = kmer[:-1], kmer[1:]

            if prefix in nodelabel2index:
                prefix_node_ind = nodelabel2index[prefix]
            else:
                prefix_node_ind = len(nodelabel2index)
                nodelabel2index[prefix] = prefix_node_ind
                nodeindex2label[prefix_node_ind] = prefix

            if suffix in nodelabel2index:
                suffix_node_ind = nodelabel2index[suffix]
            else:
                suffix_node_ind = len(nodelabel2index)
                nodelabel2index[suffix] = suffix_node_ind
                nodeindex2label[suffix_node_ind] = suffix

            length = 1
            coverage = [coverage]
            label = cls._generate_label({cls.length: length,
                                         cls.coverage: coverage,
                                         cls.edge_index: edge_index})
            nx_graph.add_edge(prefix_node_ind, suffix_node_ind,
                              string=kmer,
                              length=length,
                              coverage=coverage,
                              label=label,
                              color=color,
                              edge_index=edge_index)

        def remove_lowcov_tips():
            while True:
                edges_to_remove = []
                for s, e, key, data in nx_graph.edges(keys=True, data=True):
                    edge = (s, e, key)
                    cov = data[cls.coverage]
                    # We save coverage as list due to subsequent collapsing
                    # At this stage we did not collapse yet
                    assert len(cov) == 1
                    cov = cov[0]
                    indegree = nx_graph.in_degree(s)
                    outdegree = nx_graph.out_degree(e)
                    is_tip = (indegree == 0) or (outdegree == 0)
                    if is_tip and cov < min_tip_cov:
                        edges_to_remove.append((edge, indegree, outdegree))

                if len(edges_to_remove) == 0:
                    break

                for (s, e, key), indegree, outdegree in edges_to_remove:
                    nx_graph.remove_edge(s, e, key)

            isolates = list(nx.isolates(nx_graph))
            nx_graph.remove_nodes_from(isolates)
            for isolate in isolates:
                label = nodeindex2label[isolate]
                del nodeindex2label[isolate]
                del nodelabel2index[label]

        nx_graph = nx.MultiDiGraph()
        nodeindex2label = {}
        nodelabel2index = {}
        kmers = [tuple(kmer) for kmer in kmers]
        edge_index = 0
        for kmer in kmers:
            if kmer_coverages is None:
                add_kmer(kmer, edge_index=edge_index)
            else:
                add_kmer(kmer,
                         coverage=kmer_coverages[kmer],
                         edge_index=edge_index)
            edge_index += 1

        assert len(kmers)
        k = len(kmers[0])
        assert all(len(kmer) == k for kmer in kmers)

        remove_lowcov_tips()

        db_graph = cls(nx_graph=nx_graph,
                       nodeindex2label=nodeindex2label,
                       nodelabel2index=nodelabel2index,
                       k=k,
                       collapse=collapse)
        return db_graph

    def get_complex_nodes(self):
        complex_nodes = []
        for node in self.nx_graph.nodes():
            indegree = self.nx_graph.in_degree(node)
            outdegree = self.nx_graph.out_degree(node)
            if indegree > 1 and outdegree > 1:
                complex_nodes.append(node)
        return complex_nodes

    def get_paths_thru_complex_nodes(self, kmer_index, min_mult=4):
        complex_nodes = self.get_complex_nodes()
        k = self.k

        selected_kp1mers = {}
        for node in complex_nodes:
            for in_edge in self.nx_graph.in_edges(node,
                                                  keys=True, data=True):
                for out_edge in self.nx_graph.out_edges(node,
                                                        keys=True, data=True):
                    in_kmer = in_edge[3][self.string][-k:]
                    out_kmer = out_edge[3][self.string][:k]

                    assert in_kmer[1:] == \
                        out_kmer[:-1] == \
                        self.nodeindex2label[node]

                    kp1 = in_kmer + (out_kmer[-1],)
                    if kp1 in kmer_index and len(kmer_index[kp1]) >= min_mult:
                        selected_kp1mers[kp1] = len(kmer_index[kp1])
        return selected_kp1mers

    def get_all_kmers(self):
        kmers = {}
        for s, e, key, data in self.nx_graph.edges(keys=True, data=True):
            coverage = data[self.coverage]
            string = data[self.string]
            assert len(coverage) == len(string)-self.k+1
            for i in range(len(string)-self.k+1):
                kmer = string[i:i+self.k]
                kmer = tuple(kmer)
                kmers[kmer] = coverage[i]
        return kmers

    def get_unique_edges(self, paths=None):
        def get_topologically_unique_edges(db):
            db_cnds = nx.condensation(db.nx_graph)
            edges = []
            for s, e in db_cnds.edges:
                scc1, scc2 = db_cnds.nodes[s], db_cnds.nodes[e]
                scc1 = scc1['members']
                scc2 = scc2['members']
                for n1 in scc1:
                    for n2 in scc2:
                        key = 0
                        while True:
                            if db.nx_graph.has_edge(n1, n2, key=key):
                                edges.append((n1, n2, key))
                                key += 1
                            else:
                                break
            edges = set(edges)
            return edges

        def get_mapping_unique_edges(chains):
            l_ext, r_ext = defaultdict(list), defaultdict(list)
            non_unique = set()

            for r_id, r_chains in chains.items():
                # use uniquely mapped reads
                if len(r_chains) != 1:
                    continue
                chain = r_chains[0]
                path = [overlap.edge for overlap in chain.overlap_list]
                edges_cnt = Counter(path)
                for edge, cnt in edges_cnt.items():
                    if cnt > 1:
                        non_unique.add(edge)

            for r_id, (path, e_st, e_en) in paths.items():
                for i, edge in enumerate(path):
                    if edge in non_unique:
                        continue
                    ex_l_ext, ex_r_ext = l_ext[edge], r_ext[edge]
                    c_l_ext, c_r_ext = path[:i], path[i+1:]
                    min_l_ext = min(len(c_l_ext), len(ex_l_ext))
                    min_r_ext = min(len(c_r_ext), len(ex_r_ext))

                    if min_l_ext != 0 and \
                            c_l_ext[-min_l_ext:] != ex_l_ext[-min_l_ext:]:
                        non_unique.add(edge)
                        continue
                    if c_r_ext[:min_r_ext] != ex_r_ext[:min_r_ext]:
                        non_unique.add(edge)
                        continue

                    if len(c_l_ext) > len(ex_l_ext):
                        l_ext[edge] = c_l_ext
                    if len(c_r_ext) > len(ex_r_ext):
                        r_ext[edge] = c_r_ext

            unique = set(l_ext.keys()) - non_unique
            return unique

        unique_edges = get_topologically_unique_edges(self)
        if paths is not None:
            unique_edges |= get_mapping_unique_edges(paths)
        logger.info('Unique edges:')
        for edge in unique_edges:
            logger.info(f'\t{edge}')
        return unique_edges

    def map_strings(self, string_set, neutral_symbs,
                    only_unique_paths=False,
                    outdir=None,
                    n_threads=config['common']['threads'],
                    min_len=None):
        if min_len is None:
            logger.info(f'For De Bruijn graph aligning min_len = k = {self.k}')
            min_len = self.k
        return super().map_strings(string_set=string_set,
                                   overlap_penalty=self.k,
                                   neutral_symbs=neutral_symbs,
                                   only_unique_paths=only_unique_paths,
                                   outdir=outdir,
                                   n_threads=n_threads,
                                   min_len=min_len)
