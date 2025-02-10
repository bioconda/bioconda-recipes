# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

from collections import Counter
import logging
import os

import networkx as nx

from sequence_graph.db_graph import DeBruijnGraph
import sequence_graph.db_graph_3col
from utils.kmers import get_kmer_index, \
    def_get_min_mult, def_get_frequent_kmers
from utils.os_utils import smart_makedirs

logger = logging.getLogger("centroFlye.sequence_graph.idb_graph")


def get_idb(string_set,
            mink, maxk,
            outdir,
            mode='ont',
            assembly=None,
            get_min_mult=None,
            get_frequent_kmers=None,
            all_kmer_index=None,
            ignored_chars=None,
            step=1):

    if outdir is not None:
        logger.info(f'IDB will be saved to {outdir}')
        smart_makedirs(outdir)
    else:
        logger.info('IDB will not be saved — outdir is None')

    assert mode in ['ont', 'hifi', 'assembly']
    if get_min_mult is None:
        get_min_mult = def_get_min_mult
    if get_frequent_kmers is None:
        get_frequent_kmers = def_get_frequent_kmers

    if all_kmer_index is None:
        all_kmer_index = get_kmer_index(seqs=string_set,
                                        mink=mink, maxk=maxk,
                                        ignored_chars=ignored_chars)
    else:
        assert all(k in all_kmer_index.keys()
                   for k in range(mink, maxk+1, step))

    dbs = {}
    all_frequent_kmers = {}

    contig_kmers = {}
    complex_kp1mers = {}
    for k in range(mink, maxk+1, step):
        min_mult = get_min_mult(k=k, mode=mode)
        kmer_index = all_kmer_index[k]
        frequent_kmers = get_frequent_kmers(kmer_index=kmer_index,
                                            string_set=string_set,
                                            min_mult=min_mult)
        # extending frequent kmers with contig kmers
        for kmer, cnt in contig_kmers.items():
            if kmer not in frequent_kmers:
                frequent_kmers[kmer] = cnt

        # extending frequent kmers with k+1-mers that pass through complex
        # nodes
        for kmer, cnt in complex_kp1mers.items():
            if kmer in frequent_kmers:
                assert cnt == frequent_kmers[kmer]
        frequent_kmers.update(complex_kp1mers)

        all_frequent_kmers[k] = frequent_kmers

        logger.info(f'k={k}')
        logger.info(f'#frequent kmers = {len(frequent_kmers)}')
        logger.info(f'min_mult = {min_mult}')

        db = DeBruijnGraph.from_kmers(kmers=frequent_kmers.keys(),
                                      kmer_coverages=frequent_kmers,
                                      min_tip_cov=min_mult)
        ncc = nx.number_weakly_connected_components(db.nx_graph)
        logger.info(f'#cc = {ncc}')
        for i, cc in enumerate(nx.weakly_connected_components(db.nx_graph)):
            logger.info(f'{i}-th cc is of size = {len(cc)}')

        if outdir is not None:
            dot_file = os.path.join(outdir, f'db_k{k}.dot')
            db.write_dot(outfile=dot_file, export_pdf=False)

            dot_compact_file = os.path.join(outdir, f'db_k{k}_compact.dot')
            db.write_dot(outfile=dot_compact_file,
                         export_pdf=True,
                         compact=True)
            pickle_file = os.path.join(outdir, f'db_k{k}.pickle')
            db.pickle_dump(pickle_file)

            if assembly is not None:
                sequence_graph.db_graph_3col.DeBruijnGraph3Color.\
                    from_read_db_and_assembly(gr_reads=db,
                                              assembly=assembly,
                                              outdir=outdir)
        dbs[k] = db

        if k < maxk:
            contigs, _ = db.get_contigs()
            contig_kmers = Counter()
            for contig in contigs:
                for i in range(len(contig)-(k+1)+1):
                    kmer = contig[i:i+k+1]
                    contig_kmers[kmer] += 1

            complex_kp1mers = \
                db.get_paths_thru_complex_nodes(all_kmer_index[k+1])
    return dbs, all_frequent_kmers


def get_db(string_set,
           k,
           outdir,
           mode='ont',
           assembly=None,
           get_min_mult=None,
           get_frequent_kmers=None,
           kmer_index=None,
           step=1):
    if kmer_index is not None:
        all_kmer_index = {k: kmer_index}
    else:
        all_kmer_index = None
    dbs, all_frequent_kmers = \
        get_idb(string_set=string_set,
                mink=k, maxk=k,
                outdir=outdir,
                mode=mode,
                assembly=assembly,
                get_min_mult=get_min_mult,
                get_frequent_kmers=get_frequent_kmers,
                all_kmer_index=all_kmer_index,
                step=step)
    db = dbs[k]
    frequent_kmers = all_frequent_kmers[k]
    return db, frequent_kmers


def get_idb_monostring_set(string_set,
                           mink, maxk,
                           outdir,
                           mode='ont',
                           assembly=None,
                           get_min_mult=None,
                           get_frequent_kmers=None,
                           all_kmer_index=None,
                           step=1):
    if all_kmer_index is None:
        all_kmer_index = string_set.get_kmer_index(mink=mink, maxk=maxk)

    return get_idb(string_set=string_set,
                   mink=mink, maxk=maxk,
                   outdir=outdir,
                   mode=mode,
                   assembly=assembly,
                   get_min_mult=get_min_mult,
                   get_frequent_kmers=get_frequent_kmers,
                   all_kmer_index=all_kmer_index,
                   step=step)


def get_db_monostring_set(string_set,
                          k,
                          outdir,
                          mode='ont',
                          assembly=None,
                          get_min_mult=None,
                          get_frequent_kmers=None,
                          kmer_index=None,
                          step=1):
    if kmer_index is None:
        all_kmer_index = string_set.get_kmer_index(mink=k, maxk=k)
    else:
        all_kmer_index = {k: kmer_index}
    dbs, all_frequent_kmers = \
        get_idb_monostring_set(string_set=string_set,
                               mink=k, maxk=k,
                               outdir=outdir,
                               mode=mode,
                               assembly=assembly,
                               get_min_mult=get_min_mult,
                               get_frequent_kmers=get_frequent_kmers,
                               all_kmer_index=all_kmer_index,
                               step=step)
    db = dbs[k]
    frequent_kmers = all_frequent_kmers[k]
    return db, frequent_kmers
