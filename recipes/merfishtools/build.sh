#!/bin/bash 

set -xe

# build statically linked binary with Rust and install it to $PREFIX/bin
LIBRARY_PATH=$PREFIX/lib cargo install --root ${PREFIX} --path .

# install the Python package
$PYTHON setup.py install
