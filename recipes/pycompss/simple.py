#!/usr/bin/python

# -*- coding: utf-8 -*-

"""
PyCOMPSs Testbench Simple
========================
"""

# Imports
from pycompss.api.parameter import *
from pycompss.api.task import task
import unittest


@task(file_path=FILE_INOUT)
def increment(file_path):
    print("Init task user code")
    # Read value
    fis = open(file_path, 'r')
    value = fis.read()
    print("Received " + value)
    fis.close()

    # Write value
    fos = open(file_path, 'w')
    new_value = str(int(value) + 1)
    print("Computed " + new_value)
    fos.write(new_value)
    fos.close()


def usage():
    print("[ERROR] Bad number of parameters")
    print("    Usage: simple <counterValue>")


class SimpleTest(unittest.TestCase):
    def test_simple(self):
        from pycompss.api.api import compss_open

        initial_value = '1'
        file_name = "counter"

        # Write value
        fos = open(file_name, 'w')
        fos.write(initial_value)
        fos.close()
        print("Initial counter value is " + initial_value)

        # Execute increment
        increment(file_name)

        # Write new value
        fis = compss_open(file_name, 'r+')
        final_value = fis.read()
        fis.close()
        print("Final counter value is " + final_value)

        expected_final_value = '2'
        if final_value != expected_final_value:
            print("Simple increment test result is incorrect. "
                  "Expected: %s, got: %s" % (expected_final_value, final_value))
        self.assertEqual(final_value, expected_final_value)


if __name__ == '__main__':
    unittest.main()
