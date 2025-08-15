#!/bin/bash

set -ex
mkdir -p ${PREFIX}/bin

# Setup PLAST binaries
cp build/bin/plast $PREFIX/bin/
chmod +x $PREFIX/bin/plast

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON -m pip install ./ete3 --no-deps --ignore-installed -vv
