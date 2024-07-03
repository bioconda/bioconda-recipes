#!/bin/bash
set -e

# Install primerforge using pip
python3 -m pip install $SRC_DIR --no-deps --no-build-isolation -vvv

# Install khmer
wget https://github.com/dib-lab/khmer/archive/refs/tags/v2.1.1.tar.gz
tar xzf v2.1.1.tar.gz
cd khmer-2.1.1
python3 setup.py install
