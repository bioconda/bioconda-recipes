#!/bin/bash
set -xe
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
mkdir -p $PREFIX/bin/
cp pyngoST/*.py $PREFIX/bin/
chmod +x $PREFIX/bin/pyngoST.py
chmod +x $PREFIX/bin/pyngoST_utils.py

