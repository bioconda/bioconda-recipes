# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

import logging
import os

import networkx as nx
import numpy as np

import sequence_graph.idb_graph
from sequence_graph.seq_graph import SequenceGraph
from utils.os_utils import smart_makedirs

logger = logging.getLogger("centroFlye.sequence_graph.db_graph_3col")


class DeBruijnGraph3Color(SequenceGraph):
    read_coverage = 'read_coverage'
    assembly_coverage = 'assembly_coverage'
    col_assembly = 'blue'
    col_reads = 'red'
    col_both = 'green'

    def __init__(self, nx_graph, nodeindex2label, nodelabel2index, k,
                 collapse=True):
        super().__init__(nx_graph=nx_graph,
                         nodeindex2label=nodeindex2label,
                         nodelabel2index=nodelabel2index,
                         collapse=collapse)
        self.k = k  # length of an edge in the uncompressed graph

    @classmethod
    def _generate_label(cls, par_dict):
        length = par_dict[cls.length]
        read_cov = par_dict[cls.read_coverage]
        assembly_cov = par_dict[cls.assembly_coverage]
        edge_index = par_dict[cls.edge_index]

        label = f'index={edge_index}\n'

        if read_cov is None:
            mean_assembly_cov = np.mean(assembly_cov)
            label += f'len={length}\nAssemblyCov={mean_assembly_cov:0.2f}'
        elif assembly_cov is None:
            mean_read_cov = np.mean(read_cov)
            label += f'len={length}\nReadCov={mean_read_cov:0.2f}'
        else:
            assert read_cov is not None and assembly_cov is not None
            mean_assembly_cov = np.mean(assembly_cov)
            mean_read_cov = np.mean(read_cov)
            label += f'len={length}\nAssemblyCov={mean_assembly_cov:0.2f}\n'
            label += f'ReadCov={mean_read_cov:0.2f}'
        return label

    @classmethod
    def from_db_graphs(cls, gr_assembly, gr_reads, collapse=True):
        def add_kmer(kmer, read_coverage, assembly_coverage, color,
                     edge_index):
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
            if read_coverage is not None:
                read_coverage = [read_coverage]
            if assembly_coverage is not None:
                assembly_coverage = [assembly_coverage]
            label = \
                cls._generate_label({cls.length: length,
                                     cls.read_coverage: read_coverage,
                                     cls.assembly_coverage: assembly_coverage,
                                     cls.edge_index: edge_index})
            nx_graph.add_edge(prefix_node_ind, suffix_node_ind,
                              string=kmer,
                              length=length,
                              read_coverage=read_coverage,
                              assembly_coverage=assembly_coverage,
                              label=label,
                              color=color,
                              edge_index=edge_index)

        kmers_assembly_cov = gr_assembly.get_all_kmers()
        kmers_reads_cov = gr_reads.get_all_kmers()

        kmers_assembly = set(kmers_assembly_cov.keys())
        kmers_reads = set(kmers_reads_cov.keys())
        kmers_both = kmers_assembly & kmers_reads
        kmers_assembly = kmers_assembly - kmers_both
        kmers_reads = kmers_reads - kmers_both

        nx_graph = nx.MultiDiGraph()
        nodeindex2label = {}
        nodelabel2index = {}
        edge_index = 0

        for kmer in kmers_both:
            add_kmer(kmer, read_coverage=kmers_reads_cov[kmer],
                     assembly_coverage=kmers_assembly_cov[kmer],
                     color=cls.col_both,
                     edge_index=edge_index)
            edge_index += 1
        for kmer in kmers_reads:
            add_kmer(kmer, read_coverage=kmers_reads_cov[kmer],
                     assembly_coverage=None,
                     color=cls.col_reads,
                     edge_index=edge_index)
            edge_index += 1
        for kmer in kmers_assembly:
            add_kmer(kmer, read_coverage=None,
                     assembly_coverage=kmers_assembly_cov[kmer],
                     color=cls.col_assembly,
                     edge_index=edge_index)
            edge_index += 1

        k = gr_assembly.k
        assert k == gr_reads.k

        db_graph = cls(nx_graph=nx_graph,
                       nodeindex2label=nodeindex2label,
                       nodelabel2index=nodelabel2index,
                       k=k,
                       collapse=collapse)
        return db_graph

    @classmethod
    def from_read_db_and_assembly(cls, gr_reads, assembly, outdir=None):
        k = gr_reads.k
        gr_assembly, _ = sequence_graph.idb_graph.get_db_monostring_set(
            assembly, k=k, outdir=None, mode='assembly')
        color3graph = cls.from_db_graphs(gr_assembly=gr_assembly,
                                         gr_reads=gr_reads)
        if outdir is not None:
            smart_makedirs(outdir)

            asm_dot_file = os.path.join(outdir, f'db_asm_k{k}.dot')
            gr_assembly.write_dot(outfile=asm_dot_file, export_pdf=False)

            asm_dot_compact_file = os.path.join(outdir,
                                                f'db_asm_k{k}_compact.dot')
            gr_assembly.write_dot(outfile=asm_dot_compact_file,
                                  export_pdf=True,
                                  compact=True)
            asm_pickle_file = os.path.join(outdir, f'db_asm_k{k}.pickle')
            gr_assembly.pickle_dump(asm_pickle_file)

            c3g_dot_file = os.path.join(outdir, f'c3g_k{k}.dot')
            color3graph.write_dot(outfile=c3g_dot_file,
                                  export_pdf=True,
                                  compact=True)
            c3g_pickle_file = os.path.join(outdir, f'c3g_k{k}.pickle')
            color3graph.pickle_dump(c3g_pickle_file)
        return color3graph

    def _add_edge(self, color, string,
                  in_node, out_node,
                  in_data, out_data,
                  edge_len,
                  edge_index):
        in_read_cov = in_data[self.read_coverage]
        out_read_cov = out_data[self.read_coverage]

        in_assembly_cov = in_data[self.assembly_coverage]
        out_assembly_cov = out_data[self.assembly_coverage]

        assert (in_read_cov is None) == (out_read_cov is None)
        assert (in_assembly_cov is None) == (out_assembly_cov is None)
        assert not (in_read_cov is None and out_read_cov is None and
                    in_assembly_cov is None and out_assembly_cov is None)
        if in_read_cov is not None:
            read_cov = sorted(in_read_cov + out_read_cov)
            assert len(read_cov) == edge_len
        else:
            read_cov = None
        if in_assembly_cov is not None:
            assembly_cov = sorted(in_assembly_cov + out_assembly_cov)
            assert len(assembly_cov) == edge_len
        else:
            assembly_cov = None

        label = \
            self._generate_label({self.length: edge_len,
                                  self.read_coverage: read_cov,
                                  self.assembly_coverage: assembly_cov,
                                  self.edge_index: edge_index})
        key = self.nx_graph.add_edge(in_node, out_node,
                                     string=string,
                                     length=edge_len,
                                     read_coverage=read_cov,
                                     assembly_coverage=assembly_cov,
                                     label=label,
                                     color=color,
                                     edge_index=edge_index)
        self.edge_index2edge[edge_index] = (in_node, out_node, key)


    def get_kmers_on_edges(self, color=None):
        kmer2edge = {}
        edge2kmer = {}
        for s, e, key, data in self.nx_graph.edges(keys=True, data=True):
            if color is not None and data[self.color] != color:
                continue

            edge = (s, e, key)
            edge2kmer[edge] = []
            string = data[self.string]
            for i in range(len(string)-self.k+1):
                kmer = string[i:i+self.k]
                kmer2edge[kmer] = (edge, i)
                edge2kmer[edge].append(kmer)
        return kmer2edge, edge2kmer

    def get_kmers_on_assembly_edges(self):
        return self.get_kmers_on_edges(color=self.col_assembly)

    def get_kmers_on_read_edges(self):
        return self.get_kmers_on_edges(color=self.col_reads)

    def get_kmers_on_assembly_read_edges(self):
        return self.get_kmers_on_edges(color=self.col_both)
