#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
intervaltree: A mutable, self-balancing interval tree for Python 2 and 3.
Queries may be by point, by range overlap, or by range envelopment.

Core logic: internal tree nodes.

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
from operator import attrgetter
from math import floor, log


def l2(num):
    """
    log base 2
    :rtype real
    """
    return log(num, 2)


class Node(object):
    def __init__(self,
                 x_center=None,
                 s_center=set(),
                 left_node=None,
                 right_node=None):
        self.x_center = x_center
        self.s_center = set(s_center)
        self.left_node = left_node
        self.right_node = right_node
        self.depth = 0    # will be set when rotated
        self.balance = 0  # ditto
        self.rotate()

    @classmethod
    def from_interval(cls, interval):
        """
        :rtype : Node
        """
        center = interval.begin
        return Node(center, [interval])

    @classmethod
    def from_intervals(cls, intervals):
        """
        :rtype : Node
        """
        if not intervals:
            return None
        node = Node()
        node = node.init_from_sorted(sorted(intervals))
        return node

    def init_from_sorted(self, intervals):
        # assumes that intervals is a non-empty collection.
        # Else, next line raises IndexError
        center_iv = intervals[len(intervals) // 2]
        self.x_center = center_iv.begin
        self.s_center = set()
        s_left = []
        s_right = []
        for k in intervals:
            if k.end <= self.x_center:
                s_left.append(k)
            elif k.begin > self.x_center:
                s_right.append(k)
            else:
                self.s_center.add(k)
        self.left_node = Node.from_intervals(s_left)
        self.right_node = Node.from_intervals(s_right)
        return self.rotate()

    def center_hit(self, interval):
        """Returns whether interval overlaps self.x_center."""
        return interval.contains_point(self.x_center)

    def hit_branch(self, interval):
        """
        Assuming not center_hit(interval), return which branch
        (left=0, right=1) interval is in.
        """
        return interval.begin > self.x_center

    def refresh_balance(self):
        """
        Recalculate self.balance and self.depth based on child node values.
        """
        left_depth = self.left_node.depth if self.left_node else 0
        right_depth = self.right_node.depth if self.right_node else 0
        self.depth = 1 + max(left_depth, right_depth)
        self.balance = right_depth - left_depth

    def compute_depth(self):
        """
        Recursively computes true depth of the subtree. Should only
        be needed for debugging. Unless something is wrong, the
        depth field should reflect the correct depth of the subtree.
        """
        left_depth = self.left_node.compute_depth() if self.left_node else 0
        right_depth = self.right_node.compute_depth() if self.right_node else 0
        return 1 + max(left_depth, right_depth)

    def rotate(self):
        """
        Does rotating, if necessary, to balance this node, and
        returns the new top node.
        """
        self.refresh_balance()
        if abs(self.balance) < 2:
            return self
        # balance > 0  is the heavy side
        my_heavy = self.balance > 0
        child_heavy = self[my_heavy].balance > 0
        if my_heavy == child_heavy or self[my_heavy].balance == 0:
            ## Heavy sides same
            #    self     save
            #  save   -> 1   self
            # 1
            #
            ## Heavy side balanced
            #    self     save         save
            #  save   -> 1   self  -> 1  self.rot()
            #  1  2         2
            return self.srotate()
        else:
            return self.drotate()

    def srotate(self):
        """Single rotation. Assumes that balance is +-2."""
        #     self        save         save
        #   save 3  ->   1   self  -> 1   self.rot()
        #  1   2            2   3
        #
        #  self            save                save
        # 3   save  ->  self  1    -> self.rot()   1
        #    2   1     3   2

        #assert(self.balance != 0)
        heavy = self.balance > 0
        light = not heavy
        save = self[heavy]
        #print("srotate: bal={},{}".format(self.balance, save.balance))
        #self.print_structure()
        self[heavy] = save[light]   # 2
        #assert(save[light])
        save[light] = self.rotate()  # Needed to ensure the 2 and 3 are balanced under new subnode

        # Some intervals may overlap both self.x_center and save.x_center
        # Promote those to the new tip of the tree
        promotees = [iv for iv in save[light].s_center if save.center_hit(iv)]
        if promotees:
            for iv in promotees:
                save[light] = save[light].remove(iv)  # may trigger pruning
            # TODO: Use Node.add() here, to simplify future balancing improvements.
            # For now, this is the same as augmenting save.s_center, but that may
            # change.
            save.s_center.update(promotees)
        save.refresh_balance()
        return save

    def drotate(self):
        # First rotation
        my_heavy = self.balance > 0
        self[my_heavy] = self[my_heavy].srotate()
        self.refresh_balance()

        # Second rotation
        result = self.srotate()

        return result

    def add(self, interval):
        """
        Returns self after adding the interval and balancing.
        """
        if self.center_hit(interval):
            self.s_center.add(interval)
            return self
        else:
            direction = self.hit_branch(interval)
            if not self[direction]:
                self[direction] = Node.from_interval(interval)
                self.refresh_balance()
                return self
            else:
                self[direction] = self[direction].add(interval)
                return self.rotate()

    def remove(self, interval):
        """
        Returns self after removing the interval and balancing.

        If interval is not present, raise ValueError.
        """
        # since this is a list, called methods can set this to [1],
        # making it true
        done = []
        return self.remove_interval_helper(interval, done, should_raise_error=True)

    def discard(self, interval):
        """
        Returns self after removing interval and balancing.

        If interval is not present, do nothing.
        """
        done = []
        return self.remove_interval_helper(interval, done, should_raise_error=False)

    def remove_interval_helper(self, interval, done, should_raise_error):
        """
        Returns self after removing interval and balancing.
        If interval doesn't exist, raise ValueError.

        This method may set done to [1] to tell all callers that
        rebalancing has completed.

        See Eternally Confuzzled's jsw_remove_r function (lines 1-32)
        in his AVL tree article for reference.
        """
        #trace = interval.begin == 347 and interval.end == 353
        #if trace: print('\nRemoving from {} interval {}'.format(
        #   self.x_center, interval))
        if self.center_hit(interval):
            #if trace: print('Hit at {}'.format(self.x_center))
            if not should_raise_error and interval not in self.s_center:
                done.append(1)
                #if trace: print('Doing nothing.')
                return self
            try:
                # raises error if interval not present - this is
                # desired.
                self.s_center.remove(interval)
            except:
                self.print_structure()
                raise KeyError(interval)
            if self.s_center:     # keep this node
                done.append(1)    # no rebalancing necessary
                #if trace: print('Removed, no rebalancing.')
                return self

            # If we reach here, no intervals are left in self.s_center.
            # So, prune self.
            return self.prune()
        else:  # interval not in s_center
            direction = self.hit_branch(interval)

            if not self[direction]:
                if should_raise_error:
                    raise ValueError
                done.append(1)
                return self

            #if trace:
            #   print('Descending to {} branch'.format(
            #       ['left', 'right'][direction]
            #       ))
            self[direction] = self[direction].remove_interval_helper(interval, done, should_raise_error)

            # Clean up
            if not done:
                #if trace:
                #    print('Rotating {}'.format(self.x_center))
                #    self.print_structure()
                return self.rotate()
            return self

    def search_overlap(self, point_list):
        """
        Returns all intervals that overlap the point_list.
        """
        result = set()
        for j in point_list:
            self.search_point(j, result)
        return result

    def search_point(self, point, result):
        """
        Returns all intervals that contain point.
        """
        for k in self.s_center:
            if k.begin <= point < k.end:
                result.add(k)
        if point < self.x_center and self[0]:
            return self[0].search_point(point, result)
        elif point > self.x_center and self[1]:
            return self[1].search_point(point, result)
        return result

    def prune(self):
        """
        On a subtree where the root node's s_center is empty,
        return a new subtree with no empty s_centers.
        """
        if not self[0] or not self[1]:    # if I have an empty branch
            direction = not self[0]       # graft the other branch here
            #if trace:
            #    print('Grafting {} branch'.format(
            #       'right' if direction else 'left'))

            result = self[direction]
            #if result: result.verify()
            return result
        else:
            # Replace the root node with the greatest predecessor.
            heir, self[0] = self[0].pop_greatest_child()
            #if trace:
            #    print('Replacing {} with {}.'.format(
            #        self.x_center, heir.x_center
            #        ))
            #    print('Removed greatest predecessor:')
            #    self.print_structure()

            #if self[0]: self[0].verify()
            #if self[1]: self[1].verify()

            # Set up the heir as the new root node
            (heir[0], heir[1]) = (self[0], self[1])
            #if trace: print('Setting up the heir:')
            #if trace: heir.print_structure()

            # popping the predecessor may have unbalanced this node;
            # fix it
            heir.refresh_balance()
            heir = heir.rotate()
            #heir.verify()
            #if trace: print('Rotated the heir:')
            #if trace: heir.print_structure()
            return heir

    def pop_greatest_child(self):
        """
        Used when pruning a node with both a left and a right branch.
        Returns (greatest_child, node), where:
          * greatest_child is a new node to replace the removed node.
          * node is the subtree after:
              - removing the greatest child
              - balancing
              - moving overlapping nodes into greatest_child

        Assumes that self.s_center is not empty.

        See Eternally Confuzzled's jsw_remove_r function (lines 34-54)
        in his AVL tree article for reference.
        """
        #print('Popping from {}'.format(self.x_center))
        if not self.right_node:         # This node is the greatest child.
            # To reduce the chances of an overlap with a parent, return
            # a child node containing the smallest possible number of
            # intervals, as close as possible to the maximum bound.
            ivs = sorted(self.s_center, key=attrgetter('end', 'begin'))
            max_iv = ivs.pop()
            new_x_center = self.x_center
            while ivs:
                next_max_iv = ivs.pop()
                if next_max_iv.end == max_iv.end: continue
                new_x_center = max(new_x_center, next_max_iv.end)
            def get_new_s_center():
                for iv in self.s_center:
                    if iv.contains_point(new_x_center): yield iv

            # Create a new node with the largest x_center possible.
            child = Node(new_x_center, get_new_s_center())
            self.s_center -= child.s_center

            #print('Pop hit! Returning child   = {}'.format(
            #    child.print_structure(tostring=True)
            #    ))
            #assert not child[0]
            #assert not child[1]

            if self.s_center:
                #print('     and returning newnode = {}'.format( self ))
                #self.verify()
                return child, self
            else:
                #print('     and returning newnode = {}'.format( self[0] ))
                #if self[0]: self[0].verify()
                return child, self[0]  # Rotate left child up

        else:
            #print('Pop descent to {}'.format(self[1].x_center))
            (greatest_child, self[1]) = self[1].pop_greatest_child()

            # Move any overlaps into greatest_child
            for iv in set(self.s_center):
                if iv.contains_point(greatest_child.x_center):
                    self.s_center.remove(iv)
                    greatest_child.add(iv)

            #print('Pop Returning child   = {}'.format(
            #    greatest_child.print_structure(tostring=True)
            #    ))
            if self.s_center:
                #print('and returning newnode = {}'.format(
                #    new_self.print_structure(tostring=True)
                #    ))
                #new_self.verify()
                self.refresh_balance()
                new_self = self.rotate()
                return greatest_child, new_self
            else:
                new_self = self.prune()
                #print('and returning prune = {}'.format(
                #    new_self.print_structure(tostring=True)
                #    ))
                #if new_self: new_self.verify()
                return greatest_child, new_self

    def contains_point(self, p):
        """
        Returns whether this node or a child overlaps p.
        """
        for iv in self.s_center:
            if iv.contains_point(p):
                return True
        branch = self[p > self.x_center]
        return branch and branch.contains_point(p)

    def all_children(self):
        return self.all_children_helper(set())

    def all_children_helper(self, result):
        result.update(self.s_center)
        if self[0]:
            self[0].all_children_helper(result)
        if self[1]:
            self[1].all_children_helper(result)
        return result

    def verify(self, parents=set()):
        """
        ## DEBUG ONLY ##
        Recursively ensures that the invariants of an interval subtree
        hold.
        """
        assert(isinstance(self.s_center, set))

        bal = self.balance
        assert abs(bal) < 2, \
            "Error: Rotation should have happened, but didn't! \n{}".format(
                self.print_structure(tostring=True)
            )
        self.refresh_balance()
        assert bal == self.balance, \
            "Error: self.balance not set correctly! \n{}".format(
                self.print_structure(tostring=True)
            )

        assert self.s_center, \
            "Error: s_center is empty! \n{}".format(
                self.print_structure(tostring=True)
            )
        for iv in self.s_center:
            assert hasattr(iv, 'begin')
            assert hasattr(iv, 'end')
            assert iv.begin < iv.end
            assert iv.overlaps(self.x_center)
            for parent in sorted(parents):
                assert not iv.contains_point(parent), \
                    "Error: Overlaps ancestor ({})! \n{}\n\n{}".format(
                        parent, iv, self.print_structure(tostring=True)
                    )
        if self[0]:
            assert self[0].x_center < self.x_center, \
                "Error: Out-of-order left child! {}".format(self.x_center)
            self[0].verify(parents.union([self.x_center]))
        if self[1]:
            assert self[1].x_center > self.x_center, \
                "Error: Out-of-order right child! {}".format(self.x_center)
            self[1].verify(parents.union([self.x_center]))

    def __getitem__(self, index):
        """
        Returns the left child if input is equivalent to False, or
        the right side otherwise.
        """
        if index:
            return self.right_node
        else:
            return self.left_node

    def __setitem__(self, key, value):
        """Sets the left (0) or right (1) child."""
        if key:
            self.right_node = value
        else:
            self.left_node = value

    def __str__(self):
        """
        Shows info about this node.

        Since Nodes are internal data structures not revealed to the
        user, I'm not bothering to make this copy-paste-executable as a
        constructor.
        """
        return "Node<{0}, depth={1}, balance={2}>".format(
            self.x_center,
            self.depth,
            self.balance
        )
        #fieldcount = 'c_count,has_l,has_r = <{}, {}, {}>'.format(
        #    len(self.s_center),
        #    bool(self.left_node),
        #    bool(self.right_node)
        #)
        #fields = [self.x_center, self.balance, fieldcount]
        #return "Node({}, b={}, {})".format(*fields)

    def count_nodes(self):
        """
        Count the number of Nodes in this subtree.
        :rtype: int
        """
        count = 1
        if self.left_node:
            count += self.left_node.count_nodes()
        if self.right_node:
            count += self.right_node.count_nodes()
        return count

    def depth_score(self, n, m):
        """
        Calculates flaws in balancing the tree.
        :param n: size of tree
        :param m: number of Nodes in tree
        :rtype: real
        """
        if n == 0:
            return 0.0

        # dopt is the optimal maximum depth of the tree
        dopt = 1 + int(floor(l2(m)))
        f = 1 / float(1 + n - dopt)
        return f * self.depth_score_helper(1, dopt)

    def depth_score_helper(self, d, dopt):
        """
        Gets a weighted count of the number of Intervals deeper than dopt.
        :param d: current depth, starting from 0
        :param dopt: optimal maximum depth of a leaf Node
        :rtype: real
        """
        # di is how may levels deeper than optimal d is
        di = d - dopt
        if di > 0:
            count = di * len(self.s_center)
        else:
            count = 0
        if self.right_node:
            count += self.right_node.depth_score_helper(d + 1, dopt)
        if self.left_node:
            count += self.left_node.depth_score_helper(d + 1, dopt)
        return count

    def print_structure(self, indent=0, tostring=False):
        """
        For debugging.
        """
        nl = '\n'
        sp = indent * '    '

        rlist = [str(self) + nl]
        if self.s_center:
            for iv in sorted(self.s_center):
                rlist.append(sp + ' ' + repr(iv) + nl)
        if self.left_node:
            rlist.append(sp + '<:  ')  # no CR
            rlist.append(self.left_node.print_structure(indent + 1, True))
        if self.right_node:
            rlist.append(sp + '>:  ')  # no CR
            rlist.append(self.right_node.print_structure(indent + 1, True))
        result = ''.join(rlist)
        if tostring:
            return result
        else:
            print(result)
