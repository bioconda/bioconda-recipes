# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

import networkx as nx
from sequence_graph.path_graph_multik import PathMultiKGraph


class DB1:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 2, string='CCT')
    nx_graph.add_edge(1, 2, string='GACT')
    nx_graph.add_edge(2, 3, string='CTA')
    nx_graph.add_edge(3, 4, string='TAG')
    nx_graph.add_edge(3, 5, string='TAA')
    nx_graph.add_edge(2, 4, string='CTGT')


pg = PathMultiKGraph.fromDB(DB1(),
                            string_set={},
                            raw_mappings={0: ([(0, 2, 0), (2, 3, 0)], 0, 0),
                                          1: ([(0, 2, 0), (2, 4, 0)], 0, 0)
                                          })

# graph starting vertex


class DBStVertex:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='AAAAA')
    nx_graph.add_edge(0, 2, string='AAACA')
    nx_graph.add_edge(0, 3, string='AAA')


pg = PathMultiKGraph.fromDB(DBStVertex(),
                            string_set={},
                            raw_mappings={0: ([(0, 1, 0)], 0, 0),
                                          1: ([(0, 2, 0)], 0, 0),
                                          2: ([(0, 3, 0)], 0, 0)})
assert pg.idb_mappings.resolved_mappings == {0: [0], 1: [1], 2: [2]}
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == [((0, 1, 0), 0), ((4, 2, 0), 1)]
assert pg.idb_mappings.resolved_mappings == {0: [0], 1: [1], 2: [2]}


# graph ending vertex
class DBEnVertex:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 3, string='AAAA')
    nx_graph.add_edge(1, 3, string='AACA')
    nx_graph.add_edge(2, 3, string='AAA')


pg = PathMultiKGraph.fromDB(DBEnVertex(),
                            string_set={},
                            raw_mappings={0: ([(0, 3, 0)], 0, 0),
                                          1: ([(1, 3, 0)], 0, 0),
                                          2: ([(2, 3, 0)], 0, 0)})
assert pg.idb_mappings.resolved_mappings == {0: [0], 1: [1], 2: [2]}
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == [((0, 3, 0), 0), ((1, 4, 0), 1)]
assert pg.idb_mappings.resolved_mappings == {0: [0], 1: [1], 2: [2]}


# graph 1-in >1-out
class DB1inVertex:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='AACAG')
    nx_graph.add_edge(1, 2, string='AGACC')
    nx_graph.add_edge(1, 3, string='AGATT')
    nx_graph.add_edge(1, 4, string='AGAGG')


pg = PathMultiKGraph.fromDB(
    DB1inVertex(), string_set={}, raw_mappings={})
assert[pg.edge2seq[pg.edge2index[edge]]
       for edge in pg.nx_graph.edges] == [list('AACAG'),
                                          ['A', 'G', 'A', 'C', 'C'],
                                          ['A', 'G', 'A', 'T', 'T'],
                                          ['A', 'G', 'A', 'G', 'G']]
pg.transform_single()
assert[pg.edge2seq[pg.edge2index[edge]]
       for edge in pg.nx_graph.edges] == [list('AACAG'),
                                          ['C', 'A', 'G', 'A', 'C', 'C'],
                                          ['C', 'A', 'G', 'A', 'T', 'T'],
                                          ['C', 'A', 'G', 'A', 'G', 'G']]


# graph >1-in 1-out
class DB1outVertex:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 3, string='CCAGA')
    nx_graph.add_edge(1, 3, string='TTAGA')
    nx_graph.add_edge(2, 3, string='GGAGA')
    nx_graph.add_edge(3, 4, string='GAAAA')


pg = PathMultiKGraph.fromDB(
    DB1outVertex(), string_set={}, raw_mappings={})
assert sorted(
    [pg.edge2seq[pg.edge2index[edge]]
     for edge in pg.nx_graph.edges]) == sorted(
    [list('CCAGA'),
     list('TTAGA'),
     list('GGAGA'),
     list('GAAAA')])
pg.transform_single()
assert sorted(
    [pg.edge2seq[pg.edge2index[edge]]
     for edge in pg.nx_graph.edges]) == sorted(
    [list('CCAGAA'),
     list('TTAGAA'),
     list('GGAGAA'),
     list('GAAAA')])


# graph with a complex vertex

class DBComplexVertex1:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 2, string='ACAAA')
    nx_graph.add_edge(1, 2, string='GGAAA')
    nx_graph.add_edge(2, 3, string='AATGC')
    nx_graph.add_edge(2, 4, string='AATT')


pg = PathMultiKGraph.fromDB(
    DBComplexVertex1(),
    string_set={},
    raw_mappings={0: ([(0, 2, 0), (2, 3, 0)], 0, 0),
                  1: ([(0, 2, 0), (2, 4, 0)], 0, 0),
                  2: ([(1, 2, 0), (2, 4, 0)], 0, 0)})
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
         [((0, 2, 0), 0), ((2, 3, 0), 1), ((2, 4, 0), 2), ((1, 2, 0), 3)]
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
    [((0, 5, 0), 0),
     ((1, 8, 0), 3),
     ((5, 3, 0), 1),
     ((5, 8, 0), 4),
     ((8, 4, 0), 2)]
assert pg.edge2seq == \
    {0: ['A', 'C', 'A', 'A', 'A'],
     1: ['A', 'A', 'A', 'T', 'G', 'C'],
     2: ['A', 'A', 'T', 'T'],
     3: ['G', 'G', 'A', 'A', 'A', 'T'],
     4: ['A', 'A', 'A', 'T']}


# graph with a complex vertex

class DBComplexVertex2:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 2, string='ACAAA')
    nx_graph.add_edge(1, 2, string='GGAAA')
    nx_graph.add_edge(2, 3, string='AATGC')
    nx_graph.add_edge(2, 4, string='AATT')


pg = PathMultiKGraph.fromDB(
    DBComplexVertex2(),
    string_set={},
    raw_mappings={0: ([(0, 2, 0), (2, 3, 0)], 0, 0),
                  1: ([(0, 2, 0), (2, 4, 0)], 0, 0),
                  2: ([(1, 2, 0), (2, 4, 0)], 0, 0),
                  3: ([(1, 2, 0), (2, 3, 0)], 0, 0)})
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
         [((0, 2, 0), 0), ((2, 3, 0), 1), ((2, 4, 0), 2), ((1, 2, 0), 3)]
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
    [((0, 5, 0), 0), ((1, 6, 0), 3), ((5, 7, 0), 4),
     ((5, 8, 0), 5), ((6, 7, 0), 6),
     ((6, 8, 0), 7), ((7, 3, 0), 1), ((8, 4, 0), 2)]
assert pg.edge2seq == \
    {0: ['A', 'C', 'A', 'A', 'A'],
     1: list('AATGC'),
     2: list('AATT'),
     3: ['G', 'G', 'A', 'A', 'A'],
     4: list('AAAT'),
     5: list('AAAT'),
     6: list('AAAT'),
     7: list('AAAT')}


# graph with a complex vertex

class DBComplexVertex3:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 2, string='CCAC')
    nx_graph.add_edge(1, 2, string='TTAC')
    nx_graph.add_edge(2, 5, string='ACG')
    nx_graph.add_edge(3, 5, string='AACG')
    nx_graph.add_edge(5, 4, string='CGTA')
    nx_graph.add_edge(5, 6, string='CGA')
    nx_graph.add_edge(6, 7, string='GACC')
    nx_graph.add_edge(6, 8, string='GATT')


pg = PathMultiKGraph.fromDB(
    DBComplexVertex3(),
    string_set={},
    raw_mappings={0: ([(0, 2, 0),
                       (2, 5, 0),
                       (5, 6, 0),
                       (6, 7, 0)],
                      0, 0),
                  1: ([(1, 2, 0),
                       (2, 5, 0),
                       (5, 4, 0)],
                      0, 0),
                  2: ([(3, 5, 0),
                       (5, 6, 0),
                       (6, 8, 0)],
                      0, 0)})
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
    [((0, 2, 0), 0), ((2, 5, 0), 1),
     ((5, 4, 0), 3), ((5, 6, 0), 4), ((1, 2, 0), 2),
     ((6, 7, 0), 6), ((6, 8, 0), 7), ((3, 5, 0), 5)]
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
    [((0, 2, 0), 0), ((2, 4, 0), 3),
     ((2, 12, 0), 8), ((1, 2, 0), 2), ((3, 12, 0), 5),
     ((12, 7, 0), 6), ((12, 8, 0), 7)]
assert pg.edge2seq == \
    {0: ['C', 'C', 'A', 'C', 'G'],
     2: ['T', 'T', 'A', 'C', 'G'],
     3: ['A', 'C', 'G', 'T', 'A'],
     5: ['A', 'A', 'C', 'G', 'A'],
     6: ['C', 'G', 'A', 'C', 'C'],
     7: ['C', 'G', 'A', 'T', 'T'],
     8: ['A', 'C', 'G', 'A']}


# graph with a loop

class DBLoop:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='CCAA')
    nx_graph.add_edge(1, 1, string='AACAA')
    nx_graph.add_edge(1, 2, string='AATT')


pg = PathMultiKGraph.fromDB(
    DBLoop(), string_set={},
    raw_mappings={0: ([(0, 1, 0), (1, 1, 0)], 0, 0),
                  1: ([(1, 1, 0), (1, 2, 0)], 0, 0)})
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == [((0, 2, 0), 0)]
pg.edge2seq
assert pg.edge2seq == \
    {0: ['C', 'C', 'A', 'A', 'C', 'A', 'A', 'T', 'T']}


# graph with a loop

class DBLoop2:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='CCAA')
    nx_graph.add_edge(1, 1, string='AACAA')
    nx_graph.add_edge(1, 1, string='AAGAA')
    nx_graph.add_edge(1, 2, string='AATT')


pg = PathMultiKGraph.fromDB(
    DBLoop2(), string_set={},
    raw_mappings={0: ([(0, 1, 0), (1, 1, 0), (1, 2, 0)], 0, 0),
                  1: ([(0, 1, 0), (1, 1, 1), (1, 2, 0)], 0, 0)})
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
         [((0, 3, 0), 0), ((3, 8, 0), 1), ((3, 8, 1), 2), ((8, 2, 0), 3)]
pg.edge2seq
assert pg.edge2seq == \
    {0: ['C', 'C', 'A', 'A'],
     1: ['C', 'A', 'A', 'C', 'A', 'A', 'T'],
     2: ['C', 'A', 'A', 'G', 'A', 'A', 'T'],
     3: ['A', 'A', 'T', 'T']}


# graph with a loop

class DBLoop3:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='CCAA')
    nx_graph.add_edge(1, 1, string='AACAA')
    nx_graph.add_edge(1, 1, string='AAGAA')
    nx_graph.add_edge(1, 2, string='AATT')
    nx_graph.add_edge(3, 1, string='GGAA')
    nx_graph.add_edge(1, 4, string='AARR')


pg = PathMultiKGraph.fromDB(
    DBLoop3(),
    string_set={},
    raw_mappings={0: ([(0, 1, 0),
                       (1, 1, 0),
                       (1, 2, 0)],
                      0, 0),
                  1: ([(3, 1, 0),
                       (1, 1, 1),
                       (1, 1, 1),
                       (1, 4, 0)],
                      0, 0),
                  2: ([(3, 1, 0),
                       (1, 2, 0)],
                      0, 0)})
pg.transform_single()
assert [(edge, pg.edge2index[edge])
        for edge in pg.nx_graph.edges] == \
    [((0, 11, 0), 0), ((3, 8, 0), 5), ((7, 10, 0), 6),
     ((7, 4, 0), 4), ((8, 10, 0), 7), ((8, 11, 0), 8),
     ((10, 7, 0), 2), ((11, 2, 0), 3)]
pg.edge2seq
assert pg.edge2seq == \
    {0: ['C', 'C', 'A', 'A', 'C', 'A', 'A', 'T'],
     2: ['A', 'A', 'G', 'A', 'A'],
     3: ['A', 'A', 'T', 'T'],
     4: ['G', 'A', 'A', 'R', 'R'],
     5: ['G', 'G', 'A', 'A'],
     6: ['G', 'A', 'A', 'G'],
     7: ['G', 'A', 'A', 'G'],
     8: ['G', 'A', 'A', 'T']}


# graph with a loop

class DBLoop4:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='CCCAA')
    nx_graph.add_edge(1, 1, string='AAAAA')
    nx_graph.add_edge(1, 2, string='AATTT')

pg = PathMultiKGraph.fromDB(
    DBLoop4(),
    string_set={},
    raw_mappings={0: ([(0, 1, 0),
                       (1, 2, 0)],
                      0, 0),
                  1: ([(1, 1, 0),
                       (1, 1, 0)],
                      0, 0)})
pg.transform_single()
assert pg.unresolved == set([5])
assert list(pg.nx_graph.edges) == [(0, 2, 0), (5, 5, 0)]
assert pg.edge2seq == {0: list('CCCAATTT'), 1: list('AAAAA')}


# graph with a loop

class DBLoop5:
    k = 3
    nx_graph = nx.MultiDiGraph()
    nx_graph.add_edge(0, 1, string='CCCAA')
    nx_graph.add_edge(1, 1, string='AACAA')
    nx_graph.add_edge(1, 2, string='AATTT')

pg = PathMultiKGraph.fromDB(
    DBLoop5(),
    string_set={},
    raw_mappings={0: ([(0, 1, 0),
                       (1, 2, 0)],
                      0, 0),
                  1: ([(1, 1, 0),
                       (1, 1, 0)],
                      0, 0)})
pg.transform_single()
assert pg.unresolved == set([5])
assert list(pg.nx_graph.edges) == [(0, 2, 0), (5, 5, 0)]
assert pg.edge2seq == {0: list('CCCAATTT'), 1: list('AACAAC')}
