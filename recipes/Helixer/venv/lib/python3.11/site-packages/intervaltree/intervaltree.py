#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
intervaltree: A mutable, self-balancing interval tree for Python 2 and 3.
Queries may be by point, by range overlap, or by range envelopment.

Core logic.

Copyright 2013-2018 Chaim Leib Halbert
Modifications Copyright 2014 Konstantin Tretyakov

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
from .interval import Interval
from .node import Node
from numbers import Number
from sortedcontainers import SortedDict
from copy import copy
from warnings import warn

try:
    from collections.abc import MutableSet  # Python 3?
except ImportError:
    from collections import MutableSet

try:
    xrange  # Python 2?
except NameError:  # pragma: no cover
    xrange = range


# noinspection PyBroadException
class IntervalTree(MutableSet):
    """
    A binary lookup tree of intervals.
    The intervals contained in the tree are represented using ``Interval(a, b, data)`` objects.
    Each such object represents a half-open interval ``[a, b)`` with optional data.

    Examples:
    ---------

    Initialize a blank tree::

        >>> tree = IntervalTree()
        >>> tree
        IntervalTree()

    Initialize a tree from an iterable set of Intervals in O(n * log n)::

        >>> tree = IntervalTree([Interval(-10, 10), Interval(-20.0, -10.0)])
        >>> tree
        IntervalTree([Interval(-20.0, -10.0), Interval(-10, 10)])
        >>> len(tree)
        2

    Note that this is a set, i.e. repeated intervals are ignored. However,
    Intervals with different data fields are regarded as different::

        >>> tree = IntervalTree([Interval(-10, 10), Interval(-10, 10), Interval(-10, 10, "x")])
        >>> tree
        IntervalTree([Interval(-10, 10), Interval(-10, 10, 'x')])
        >>> len(tree)
        2

    Insertions::
        >>> tree = IntervalTree()
        >>> tree[0:1] = "data"
        >>> tree.add(Interval(10, 20))
        >>> tree.addi(19.9, 20)
        >>> tree
        IntervalTree([Interval(0, 1, 'data'), Interval(10, 20), Interval(19.9, 20)])
        >>> tree.update([Interval(19.9, 20.1), Interval(20.1, 30)])
        >>> len(tree)
        5

        Inserting the same Interval twice does nothing::
            >>> tree = IntervalTree()
            >>> tree[-10:20] = "arbitrary data"
            >>> tree[-10:20] = None  # Note that this is also an insertion
            >>> tree
            IntervalTree([Interval(-10, 20), Interval(-10, 20, 'arbitrary data')])
            >>> tree[-10:20] = None  # This won't change anything
            >>> tree[-10:20] = "arbitrary data" # Neither will this
            >>> len(tree)
            2

    Deletions::
        >>> tree = IntervalTree(Interval(b, e) for b, e in [(-10, 10), (-20, -10), (10, 20)])
        >>> tree
        IntervalTree([Interval(-20, -10), Interval(-10, 10), Interval(10, 20)])
        >>> tree.remove(Interval(-10, 10))
        >>> tree
        IntervalTree([Interval(-20, -10), Interval(10, 20)])
        >>> tree.remove(Interval(-10, 10))
        Traceback (most recent call last):
        ...
        ValueError
        >>> tree.discard(Interval(-10, 10))  # Same as remove, but no exception on failure
        >>> tree
        IntervalTree([Interval(-20, -10), Interval(10, 20)])

    Delete intervals, overlapping a given point::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> tree.remove_overlap(1.1)
        >>> tree
        IntervalTree([Interval(-1.1, 1.1)])

    Delete intervals, overlapping an interval::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> tree.remove_overlap(0, 0.5)
        >>> tree
        IntervalTree([Interval(0.5, 1.7)])
        >>> tree.remove_overlap(1.7, 1.8)
        >>> tree
        IntervalTree([Interval(0.5, 1.7)])
        >>> tree.remove_overlap(1.6, 1.6)  # Null interval does nothing
        >>> tree
        IntervalTree([Interval(0.5, 1.7)])
        >>> tree.remove_overlap(1.6, 1.5)  # Ditto
        >>> tree
        IntervalTree([Interval(0.5, 1.7)])

    Delete intervals, enveloped in the range::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> tree.remove_envelop(-1.0, 1.5)
        >>> tree
        IntervalTree([Interval(-1.1, 1.1), Interval(0.5, 1.7)])
        >>> tree.remove_envelop(-1.1, 1.5)
        >>> tree
        IntervalTree([Interval(0.5, 1.7)])
        >>> tree.remove_envelop(0.5, 1.5)
        >>> tree
        IntervalTree([Interval(0.5, 1.7)])
        >>> tree.remove_envelop(0.5, 1.7)
        >>> tree
        IntervalTree()

    Point queries::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> assert tree[-1.1]   == set([Interval(-1.1, 1.1)])
        >>> assert tree.at(1.1) == set([Interval(-0.5, 1.5), Interval(0.5, 1.7)])   # Same as tree[1.1]
        >>> assert tree.at(1.5) == set([Interval(0.5, 1.7)])                        # Same as tree[1.5]

    Interval overlap queries

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> assert tree.overlap(1.7, 1.8) == set()
        >>> assert tree.overlap(1.5, 1.8) == set([Interval(0.5, 1.7)])
        >>> assert tree[1.5:1.8] == set([Interval(0.5, 1.7)])                       # same as previous
        >>> assert tree.overlap(1.1, 1.8) == set([Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> assert tree[1.1:1.8] == set([Interval(-0.5, 1.5), Interval(0.5, 1.7)])  # same as previous

    Interval envelop queries::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> assert tree.envelop(-0.5, 0.5) == set()
        >>> assert tree.envelop(-0.5, 1.5) == set([Interval(-0.5, 1.5)])

    Membership queries::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> Interval(-0.5, 0.5) in tree
        False
        >>> Interval(-1.1, 1.1) in tree
        True
        >>> Interval(-1.1, 1.1, "x") in tree
        False
        >>> tree.overlaps(-1.1)
        True
        >>> tree.overlaps(1.7)
        False
        >>> tree.overlaps(1.7, 1.8)
        False
        >>> tree.overlaps(-1.2, -1.1)
        False
        >>> tree.overlaps(-1.2, -1.0)
        True

    Sizing::

        >>> tree = IntervalTree([Interval(-1.1, 1.1), Interval(-0.5, 1.5), Interval(0.5, 1.7)])
        >>> len(tree)
        3
        >>> tree.is_empty()
        False
        >>> IntervalTree().is_empty()
        True
        >>> not tree
        False
        >>> not IntervalTree()
        True
        >>> print(tree.begin())    # using print() because of floats in Python 2.6
        -1.1
        >>> print(tree.end())      # ditto
        1.7

    Iteration::

        >>> tree = IntervalTree([Interval(-11, 11), Interval(-5, 15), Interval(5, 17)])
        >>> [iv.begin for iv in sorted(tree)]
        [-11, -5, 5]
        >>> assert tree.items() == set([Interval(-5, 15), Interval(-11, 11), Interval(5, 17)])

    Copy- and typecasting, pickling::

        >>> tree0 = IntervalTree([Interval(0, 1, "x"), Interval(1, 2, ["x"])])
        >>> tree1 = IntervalTree(tree0)  # Shares Interval objects
        >>> tree2 = tree0.copy()         # Shallow copy (same as above, as Intervals are singletons)
        >>> import pickle
        >>> tree3 = pickle.loads(pickle.dumps(tree0))  # Deep copy
        >>> list(tree0[1])[0].data[0] = "y"  # affects shallow copies, but not deep copies
        >>> tree0
        IntervalTree([Interval(0, 1, 'x'), Interval(1, 2, ['y'])])
        >>> tree1
        IntervalTree([Interval(0, 1, 'x'), Interval(1, 2, ['y'])])
        >>> tree2
        IntervalTree([Interval(0, 1, 'x'), Interval(1, 2, ['y'])])
        >>> tree3
        IntervalTree([Interval(0, 1, 'x'), Interval(1, 2, ['x'])])

    Equality testing::

        >>> IntervalTree([Interval(0, 1)]) == IntervalTree([Interval(0, 1)])
        True
        >>> IntervalTree([Interval(0, 1)]) == IntervalTree([Interval(0, 1, "x")])
        False
    """
    @classmethod
    def from_tuples(cls, tups):
        """
        Create a new IntervalTree from an iterable of 2- or 3-tuples,
         where the tuple lists begin, end, and optionally data.
        """
        ivs = [Interval(*t) for t in tups]
        return IntervalTree(ivs)

    def __init__(self, intervals=None):
        """
        Set up a tree. If intervals is provided, add all the intervals
        to the tree.

        Completes in O(n*log n) time.
        """
        intervals = set(intervals) if intervals is not None else set()
        for iv in intervals:
            if iv.is_null():
                raise ValueError(
                    "IntervalTree: Null Interval objects not allowed in IntervalTree:"
                    " {0}".format(iv)
                )
        self.all_intervals = intervals
        self.top_node = Node.from_intervals(self.all_intervals)
        self.boundary_table = SortedDict()
        for iv in self.all_intervals:
            self._add_boundaries(iv)

    def copy(self):
        """
        Construct a new IntervalTree using shallow copies of the
        intervals in the source tree.

        Completes in O(n*log n) time.
        :rtype: IntervalTree
        """
        return IntervalTree(iv.copy() for iv in self)

    def _add_boundaries(self, interval):
        """
        Records the boundaries of the interval in the boundary table.
        """
        begin = interval.begin
        end = interval.end
        if begin in self.boundary_table:
            self.boundary_table[begin] += 1
        else:
            self.boundary_table[begin] = 1

        if end in self.boundary_table:
            self.boundary_table[end] += 1
        else:
            self.boundary_table[end] = 1

    def _remove_boundaries(self, interval):
        """
        Removes the boundaries of the interval from the boundary table.
        """
        begin = interval.begin
        end = interval.end
        if self.boundary_table[begin] == 1:
            del self.boundary_table[begin]
        else:
            self.boundary_table[begin] -= 1

        if self.boundary_table[end] == 1:
            del self.boundary_table[end]
        else:
            self.boundary_table[end] -= 1

    def add(self, interval):
        """
        Adds an interval to the tree, if not already present.

        Completes in O(log n) time.
        """
        if interval in self:
            return

        if interval.is_null():
            raise ValueError(
                "IntervalTree: Null Interval objects not allowed in IntervalTree:"
                " {0}".format(interval)
            )

        if not self.top_node:
            self.top_node = Node.from_interval(interval)
        else:
            self.top_node = self.top_node.add(interval)
        self.all_intervals.add(interval)
        self._add_boundaries(interval)
    append = add

    def addi(self, begin, end, data=None):
        """
        Shortcut for add(Interval(begin, end, data)).

        Completes in O(log n) time.
        """
        return self.add(Interval(begin, end, data))
    appendi = addi

    def update(self, intervals):
        """
        Given an iterable of intervals, add them to the tree.

        Completes in O(m*log(n+m), where m = number of intervals to
        add.
        """
        for iv in intervals:
            self.add(iv)

    def remove(self, interval):
        """
        Removes an interval from the tree, if present. If not, raises
        ValueError.

        Completes in O(log n) time.
        """
        #self.verify()
        if interval not in self:
            #print(self.all_intervals)
            raise ValueError
        self.top_node = self.top_node.remove(interval)
        self.all_intervals.remove(interval)
        self._remove_boundaries(interval)
        #self.verify()

    def removei(self, begin, end, data=None):
        """
        Shortcut for remove(Interval(begin, end, data)).

        Completes in O(log n) time.
        """
        return self.remove(Interval(begin, end, data))

    def discard(self, interval):
        """
        Removes an interval from the tree, if present. If not, does
        nothing.

        Completes in O(log n) time.
        """
        if interval not in self:
            return
        self.all_intervals.discard(interval)
        self.top_node = self.top_node.discard(interval)
        self._remove_boundaries(interval)

    def discardi(self, begin, end, data=None):
        """
        Shortcut for discard(Interval(begin, end, data)).

        Completes in O(log n) time.
        """
        return self.discard(Interval(begin, end, data))

    def difference(self, other):
        """
        Returns a new tree, comprising all intervals in self but not
        in other.
        """
        ivs = set()
        for iv in self:
            if iv not in other:
                ivs.add(iv)
        return IntervalTree(ivs)

    def difference_update(self, other):
        """
        Removes all intervals in other from self.
        """
        for iv in other:
            self.discard(iv)

    def union(self, other):
        """
        Returns a new tree, comprising all intervals from self
        and other.
        """
        return IntervalTree(set(self).union(other))

    def intersection(self, other):
        """
        Returns a new tree of all intervals common to both self and
        other.
        """
        ivs = set()
        shorter, longer = sorted([self, other], key=len)
        for iv in shorter:
            if iv in longer:
                ivs.add(iv)
        return IntervalTree(ivs)

    def intersection_update(self, other):
        """
        Removes intervals from self unless they also exist in other.
        """
        ivs = list(self)
        for iv in ivs:
            if iv not in other:
                self.remove(iv)

    def symmetric_difference(self, other):
        """
        Return a tree with elements only in self or other but not
        both.
        """
        if not isinstance(other, set): other = set(other)
        me = set(self)
        ivs = me.difference(other).union(other.difference(me))
        return IntervalTree(ivs)

    def symmetric_difference_update(self, other):
        """
        Throws out all intervals except those only in self or other,
        not both.
        """
        other = set(other)
        ivs = list(self)
        for iv in ivs:
            if iv in other:
                self.remove(iv)
                other.remove(iv)
        self.update(other)

    def remove_overlap(self, begin, end=None):
        """
        Removes all intervals overlapping the given point or range.

        Completes in O((r+m)*log n) time, where:
          * n = size of the tree
          * m = number of matches
          * r = size of the search range (this is 1 for a point)
        """
        hitlist = self.at(begin) if end is None else self.overlap(begin, end)
        for iv in hitlist:
            self.remove(iv)

    def remove_envelop(self, begin, end):
        """
        Removes all intervals completely enveloped in the given range.

        Completes in O((r+m)*log n) time, where:
          * n = size of the tree
          * m = number of matches
          * r = size of the search range
        """
        hitlist = self.envelop(begin, end)
        for iv in hitlist:
            self.remove(iv)

    def chop(self, begin, end, datafunc=None):
        """
        Like remove_envelop(), but trims back Intervals hanging into
        the chopped area so that nothing overlaps.
        """
        insertions = set()
        begin_hits = [iv for iv in self.at(begin) if iv.begin < begin]
        end_hits = [iv for iv in self.at(end) if iv.end > end]

        if datafunc:
            for iv in begin_hits:
                insertions.add(Interval(iv.begin, begin, datafunc(iv, True)))
            for iv in end_hits:
                insertions.add(Interval(end, iv.end, datafunc(iv, False)))
        else:
            for iv in begin_hits:
                insertions.add(Interval(iv.begin, begin, iv.data))
            for iv in end_hits:
                insertions.add(Interval(end, iv.end, iv.data))

        self.remove_envelop(begin, end)
        self.difference_update(begin_hits)
        self.difference_update(end_hits)
        self.update(insertions)

    def slice(self, point, datafunc=None):
        """
        Split Intervals that overlap point into two new Intervals. if
        specified, uses datafunc(interval, islower=True/False) to
        set the data field of the new Intervals.
        :param point: where to slice
        :param datafunc(interval, isupper): callable returning a new
        value for the interval's data field
        """
        hitlist = set(iv for iv in self.at(point) if iv.begin < point)
        insertions = set()
        if datafunc:
            for iv in hitlist:
                insertions.add(Interval(iv.begin, point, datafunc(iv, True)))
                insertions.add(Interval(point, iv.end, datafunc(iv, False)))
        else:
            for iv in hitlist:
                insertions.add(Interval(iv.begin, point, iv.data))
                insertions.add(Interval(point, iv.end, iv.data))
        self.difference_update(hitlist)
        self.update(insertions)

    def clear(self):
        """
        Empties the tree.

        Completes in O(1) tine.
        """
        self.__init__()

    def find_nested(self):
        """
        Returns a dictionary mapping parent intervals to sets of
        intervals overlapped by and contained in the parent.

        Completes in O(n^2) time.
        :rtype: dict of [Interval, set of Interval]
        """
        result = {}

        def add_if_nested():
            if parent.contains_interval(child):
                if parent not in result:
                    result[parent] = set()
                result[parent].add(child)

        long_ivs = sorted(self.all_intervals, key=Interval.length, reverse=True)
        for i, parent in enumerate(long_ivs):
            for child in long_ivs[i + 1:]:
                add_if_nested()
        return result

    def overlaps(self, begin, end=None):
        """
        Returns whether some interval in the tree overlaps the given
        point or range.

        Completes in O(r*log n) time, where r is the size of the
        search range.
        :rtype: bool
        """
        if end is not None:
            return self.overlaps_range(begin, end)
        elif isinstance(begin, Number):
            return self.overlaps_point(begin)
        else:
            return self.overlaps_range(begin.begin, begin.end)

    def overlaps_point(self, p):
        """
        Returns whether some interval in the tree overlaps p.

        Completes in O(log n) time.
        :rtype: bool
        """
        if self.is_empty():
            return False
        return bool(self.top_node.contains_point(p))

    def overlaps_range(self, begin, end):
        """
        Returns whether some interval in the tree overlaps the given
        range. Returns False if given a null interval over which to
        test.

        Completes in O(r*log n) time, where r is the range length and n
        is the table size.
        :rtype: bool
        """
        if self.is_empty():
            return False
        elif begin >= end:
            return False
        elif self.overlaps_point(begin):
            return True
        return any(
            self.overlaps_point(bound)
            for bound in self.boundary_table
            if begin < bound < end
        )

    def split_overlaps(self):
        """
        Finds all intervals with overlapping ranges and splits them
        along the range boundaries.

        Completes in worst-case O(n^2*log n) time (many interval
        boundaries are inside many intervals), best-case O(n*log n)
        time (small number of overlaps << n per interval).
        """
        if not self:
            return
        if len(self.boundary_table) == 2:
            return

        bounds = sorted(self.boundary_table)  # get bound locations

        new_ivs = set()
        for lbound, ubound in zip(bounds[:-1], bounds[1:]):
            for iv in self[lbound]:
                new_ivs.add(Interval(lbound, ubound, iv.data))

        self.__init__(new_ivs)

    def merge_overlaps(self, data_reducer=None, data_initializer=None, strict=True):
        """
        Finds all intervals with overlapping ranges and merges them
        into a single interval. If provided, uses data_reducer and
        data_initializer with similar semantics to Python's built-in
        reduce(reducer_func[, initializer]), as follows:

        If data_reducer is set to a function, combines the data
        fields of the Intervals with
            current_reduced_data = data_reducer(current_reduced_data, new_data)
        If data_reducer is None, the merged Interval's data
        field will be set to None, ignoring all the data fields
        of the merged Intervals.

        On encountering the first Interval to merge, if
        data_initializer is None (default), uses the first
        Interval's data field as the first value for
        current_reduced_data. If data_initializer is not None,
        current_reduced_data is set to a shallow copy of
        data_initializer created with copy.copy(data_initializer).

        If strict is True (default), intervals are only merged if
        their ranges actually overlap; adjacent, touching intervals
        will not be merged. If strict is False, intervals are merged
        even if they are only end-to-end adjacent.

        Completes in O(n*logn).
        """
        if not self:
            return

        sorted_intervals = sorted(self.all_intervals)  # get sorted intervals
        merged = []
        # use mutable object to allow new_series() to modify it
        current_reduced = [None]
        higher = None  # iterating variable, which new_series() needs access to

        def new_series():
            if data_initializer is None:
                current_reduced[0] = higher.data
                merged.append(higher)
                return
            else:  # data_initializer is not None
                current_reduced[0] = copy(data_initializer)
                current_reduced[0] = data_reducer(current_reduced[0], higher.data)
                merged.append(Interval(higher.begin, higher.end, current_reduced[0]))

        for higher in sorted_intervals:
            if merged:  # series already begun
                lower = merged[-1]
                if (higher.begin < lower.end or
                    not strict and higher.begin == lower.end):  # should merge
                    upper_bound = max(lower.end, higher.end)
                    if data_reducer is not None:
                        current_reduced[0] = data_reducer(current_reduced[0], higher.data)
                    else:  # annihilate the data, since we don't know how to merge it
                        current_reduced[0] = None
                    merged[-1] = Interval(lower.begin, upper_bound, current_reduced[0])
                else:
                    new_series()
            else:  # not merged; is first of Intervals to merge
                new_series()

        self.__init__(merged)

    def merge_equals(self, data_reducer=None, data_initializer=None):
        """
        Finds all intervals with equal ranges and merges them
        into a single interval. If provided, uses data_reducer and
        data_initializer with similar semantics to Python's built-in
        reduce(reducer_func[, initializer]), as follows:

        If data_reducer is set to a function, combines the data
        fields of the Intervals with
            current_reduced_data = data_reducer(current_reduced_data, new_data)
        If data_reducer is None, the merged Interval's data
        field will be set to None, ignoring all the data fields
        of the merged Intervals.

        On encountering the first Interval to merge, if
        data_initializer is None (default), uses the first
        Interval's data field as the first value for
        current_reduced_data. If data_initializer is not None,
        current_reduced_data is set to a shallow copy of
        data_initiazer created with
            copy.copy(data_initializer).

        Completes in O(n*logn).
        """
        if not self:
            return

        sorted_intervals = sorted(self.all_intervals)  # get sorted intervals
        merged = []
        # use mutable object to allow new_series() to modify it
        current_reduced = [None]
        higher = None  # iterating variable, which new_series() needs access to

        def new_series():
            if data_initializer is None:
                current_reduced[0] = higher.data
                merged.append(higher)
                return
            else:  # data_initializer is not None
                current_reduced[0] = copy(data_initializer)
                current_reduced[0] = data_reducer(current_reduced[0], higher.data)
                merged.append(Interval(higher.begin, higher.end, current_reduced[0]))

        for higher in sorted_intervals:
            if merged:  # series already begun
                lower = merged[-1]
                if higher.range_matches(lower):  # should merge
                    upper_bound = max(lower.end, higher.end)
                    if data_reducer is not None:
                        current_reduced[0] = data_reducer(current_reduced[0], higher.data)
                    else:  # annihilate the data, since we don't know how to merge it
                        current_reduced[0] = None
                    merged[-1] = Interval(lower.begin, upper_bound, current_reduced[0])
                else:
                    new_series()
            else:  # not merged; is first of Intervals to merge
                new_series()

        self.__init__(merged)

    def items(self):
        """
        Constructs and returns a set of all intervals in the tree.

        Completes in O(n) time.
        :rtype: set of Interval
        """
        return set(self.all_intervals)

    def is_empty(self):
        """
        Returns whether the tree is empty.

        Completes in O(1) time.
        :rtype: bool
        """
        return 0 == len(self)

    def at(self, p):
        """
        Returns the set of all intervals that contain p.

        Completes in O(m + log n) time, where:
          * n = size of the tree
          * m = number of matches
        :rtype: set of Interval
        """
        root = self.top_node
        if not root:
            return set()
        return root.search_point(p, set())

    def envelop(self, begin, end=None):
        """
        Returns the set of all intervals fully contained in the range
        [begin, end).

        Completes in O(m + k*log n) time, where:
          * n = size of the tree
          * m = number of matches
          * k = size of the search range
        :rtype: set of Interval
        """
        root = self.top_node
        if not root:
            return set()
        if end is None:
            iv = begin
            return self.envelop(iv.begin, iv.end)
        elif begin >= end:
            return set()
        result = root.search_point(begin, set()) # bound_begin might be greater
        boundary_table = self.boundary_table
        bound_begin = boundary_table.bisect_left(begin)
        bound_end = boundary_table.bisect_left(end)  # up to, but not including end
        result.update(root.search_overlap(
            # slice notation is slightly slower
            boundary_table.keys()[index] for index in xrange(bound_begin, bound_end)
        ))

        # TODO: improve envelop() to use node info instead of less-efficient filtering
        result = set(
            iv for iv in result
            if iv.begin >= begin and iv.end <= end
        )
        return result

    def overlap(self, begin, end=None):
        """
        Returns a set of all intervals overlapping the given range.

        Completes in O(m + k*log n) time, where:
          * n = size of the tree
          * m = number of matches
          * k = size of the search range
        :rtype: set of Interval
        """
        root = self.top_node
        if not root:
            return set()
        if end is None:
            iv = begin
            return self.overlap(iv.begin, iv.end)
        elif begin >= end:
            return set()
        result = root.search_point(begin, set())  # bound_begin might be greater
        boundary_table = self.boundary_table
        bound_begin = boundary_table.bisect_left(begin)
        bound_end = boundary_table.bisect_left(end)  # up to, but not including end
        result.update(root.search_overlap(
            # slice notation is slightly slower
            boundary_table.keys()[index] for index in xrange(bound_begin, bound_end)
        ))
        return result

    def begin(self):
        """
        Returns the lower bound of the first interval in the tree.

        Completes in O(1) time.
        """
        if not self.boundary_table:
            return 0
        return self.boundary_table.keys()[0]

    def end(self):
        """
        Returns the upper bound of the last interval in the tree.

        Completes in O(1) time.
        """
        if not self.boundary_table:
            return 0
        return self.boundary_table.keys()[-1]

    def range(self):
        """
        Returns a minimum-spanning Interval that encloses all the
        members of this IntervalTree. If the tree is empty, returns
        null Interval.
        :rtype: Interval
        """
        return Interval(self.begin(), self.end())

    def span(self):
        """
        Returns the length of the minimum-spanning Interval that
        encloses all the members of this IntervalTree. If the tree
        is empty, return 0.
        """
        if not self:
            return 0
        return self.end() - self.begin()

    def print_structure(self, tostring=False):
        """
        ## FOR DEBUGGING ONLY ##
        Pretty-prints the structure of the tree.
        If tostring is true, prints nothing and returns a string.
        :rtype: None or str
        """
        if self.top_node:
            return self.top_node.print_structure(tostring=tostring)
        else:
            result = "<empty IntervalTree>"
            if not tostring:
                print(result)
            else:
                return result

    def verify(self):
        """
        ## FOR DEBUGGING ONLY ##
        Checks the table to ensure that the invariants are held.
        """
        if self.all_intervals:
            ## top_node.all_children() == self.all_intervals
            try:
                assert self.top_node.all_children() == self.all_intervals
            except AssertionError as e:
                print(
                    'Error: the tree and the membership set are out of sync!'
                )
                tivs = set(self.top_node.all_children())
                print('top_node.all_children() - all_intervals:')
                try:
                    pprint
                except NameError:
                    from pprint import pprint
                pprint(tivs - self.all_intervals)
                print('all_intervals - top_node.all_children():')
                pprint(self.all_intervals - tivs)
                raise e

            ## All members are Intervals
            for iv in self:
                assert isinstance(iv, Interval), (
                    "Error: Only Interval objects allowed in IntervalTree:"
                    " {0}".format(iv)
                )

            ## No null intervals
            for iv in self:
                assert not iv.is_null(), (
                    "Error: Null Interval objects not allowed in IntervalTree:"
                    " {0}".format(iv)
                )

            ## Reconstruct boundary_table
            bound_check = {}
            for iv in self:
                if iv.begin in bound_check:
                    bound_check[iv.begin] += 1
                else:
                    bound_check[iv.begin] = 1
                if iv.end in bound_check:
                    bound_check[iv.end] += 1
                else:
                    bound_check[iv.end] = 1

            ## Reconstructed boundary table (bound_check) ==? boundary_table
            assert set(self.boundary_table.keys()) == set(bound_check.keys()),\
                'Error: boundary_table is out of sync with ' \
                'the intervals in the tree!'

            # For efficiency reasons this should be iteritems in Py2, but we
            # don't care much for efficiency in debug methods anyway.
            for key, val in self.boundary_table.items():
                assert bound_check[key] == val, \
                    'Error: boundary_table[{0}] should be {1},' \
                    ' but is {2}!'.format(
                        key, bound_check[key], val)

            ## Internal tree structure
            self.top_node.verify(set())
        else:
            ## Verify empty tree
            assert not self.boundary_table, \
                "Error: boundary table should be empty!"
            assert self.top_node is None, \
                "Error: top_node isn't None!"

    def score(self, full_report=False):
        """
        Returns a number between 0 and 1, indicating how suboptimal the tree
        is. The lower, the better. Roughly, this number represents the
        fraction of flawed Intervals in the tree.
        :rtype: float
        """
        if len(self) <= 2:
            return 0.0

        n = len(self)
        m = self.top_node.count_nodes()

        def s_center_score():
            """
            Returns a normalized score, indicating roughly how many times
            intervals share s_center with other intervals. Output is full-scale
            from 0 to 1.
            :rtype: float
            """
            raw = n - m
            maximum = n - 1
            return raw / float(maximum)

        report = {
            "depth": self.top_node.depth_score(n, m),
            "s_center": s_center_score(),
        }
        cumulative = max(report.values())
        report["_cumulative"] = cumulative
        if full_report:
            return report
        return cumulative


    def __getitem__(self, index):
        """
        Returns a set of all intervals overlapping the given index or
        slice.

        Completes in O(k * log(n) + m) time, where:
          * n = size of the tree
          * m = number of matches
          * k = size of the search range (this is 1 for a point)
        :rtype: set of Interval
        """
        try:
            start, stop = index.start, index.stop
            if start is None:
                start = self.begin()
                if stop is None:
                    return set(self)
            if stop is None:
                stop = self.end()
            return self.overlap(start, stop)
        except AttributeError:
            return self.at(index)

    def __setitem__(self, index, value):
        """
        Adds a new interval to the tree. A shortcut for
        add(Interval(index.start, index.stop, value)).

        If an identical Interval object with equal range and data
        already exists, does nothing.

        Completes in O(log n) time.
        """
        self.addi(index.start, index.stop, value)

    def __delitem__(self, point):
        """
        Delete all items overlapping point.
        """
        self.remove_overlap(point)

    def __contains__(self, item):
        """
        Returns whether item exists as an Interval in the tree.
        This method only returns True for exact matches; for
        overlaps, see the overlaps() method.

        Completes in O(1) time.
        :rtype: bool
        """
        # Removed point-checking code; it might trick the user into
        # thinking that this is O(1), which point-checking isn't.
        #if isinstance(item, Interval):
        return item in self.all_intervals
        #else:
        #    return self.contains_point(item)

    def containsi(self, begin, end, data=None):
        """
        Shortcut for (Interval(begin, end, data) in tree).

        Completes in O(1) time.
        :rtype: bool
        """
        return Interval(begin, end, data) in self

    def __iter__(self):
        """
        Returns an iterator over all the intervals in the tree.

        Completes in O(1) time.
        :rtype: collections.Iterable[Interval]
        """
        return self.all_intervals.__iter__()
    iter = __iter__

    def __len__(self):
        """
        Returns how many intervals are in the tree.

        Completes in O(1) time.
        :rtype: int
        """
        return len(self.all_intervals)

    def __eq__(self, other):
        """
        Whether two IntervalTrees are equal.

        Completes in O(n) time if sizes are equal; O(1) time otherwise.
        :rtype: bool
        """
        return (
            isinstance(other, IntervalTree) and
            self.all_intervals == other.all_intervals
        )

    def __repr__(self):
        """
        :rtype: str
        """
        ivs = sorted(self)
        if not ivs:
            return "IntervalTree()"
        else:
            return "IntervalTree({0})".format(ivs)

    __str__ = __repr__

    def __reduce__(self):
        """
        For pickle-ing.
        :rtype: tuple
        """
        return IntervalTree, (sorted(self.all_intervals),)

