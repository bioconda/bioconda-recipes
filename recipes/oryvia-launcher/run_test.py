"""Run the complete source suite in conda-build's test environment.

Bioconda's final minimal image replays only meta.yaml test commands; it does
not copy test/source_files. Keep those commands limited to installed CLI checks.
"""
from pathlib import Path
import sys
import unittest

test_dir = Path(__file__).resolve().parent / "tests"
suite = unittest.defaultTestLoader.discover(str(test_dir), pattern="test_launcher.py")
expected_tests = 26
if suite.countTestCases() != expected_tests:
    raise RuntimeError(f"Expected {expected_tests} launcher tests, found {suite.countTestCases()}")
result = unittest.TextTestRunner(verbosity=2).run(suite)
if result.testsRun != expected_tests:
    raise RuntimeError(f"Expected to run {expected_tests} launcher tests, ran {result.testsRun}")
sys.exit(0 if result.wasSuccessful() else 1)
