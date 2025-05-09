#!/bin/bash
set -eux

# Install pip-only deps in the test env
$PYTHON -m pip install pypdf pymupdf alive-progress

# Run test
SigProfilerAssignment --help