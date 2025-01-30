#!/usr/bin/env python

import unittest

import numpy as np
import pycoverm


class TestPycoverm(unittest.TestCase):
    def setUp(self):
        self.bam_file = "test.bam"

    def test_is_bam_sorted(self):
        result = pycoverm.is_bam_sorted(self.bam_file)
        self.assertIsInstance(result, bool)

    def test_get_coverages_from_bam(self):
        result = pycoverm.get_coverages_from_bam([self.bam_file])
        self.assertIsInstance(result[0], list)
        self.assertIsInstance(result[1], np.ndarray)
        self.assertAlmostEqual(result[1].sum(), 30.173173904418945)


if __name__ == "__main__":
    unittest.main()
