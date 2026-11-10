#!/bin/bash
set -ex

bash admin/builders/conda_build.sh

# Test input for the package test. bioconda repeats the test in a container
# without the source, so the file is installed with the package.
mkdir -p "${PREFIX}/testdata"
cp -f data/percolator/tab/percolatorTab "${PREFIX}/testdata/percolatorTab"
