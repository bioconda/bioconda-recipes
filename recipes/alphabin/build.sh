#!/bin/bash
set -euxo pipefail

# 1) R engine: compiles the C++ kernels and installs the pipeline stages
${R} CMD INSTALL --build R-package/alphabin

# 2) Python command-line tool (`alphabin` entry point)
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv
