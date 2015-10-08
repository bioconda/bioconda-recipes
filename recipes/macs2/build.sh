#!/bin/bash
pushd $SRC_DIR
# From setup.py: User must check GCC, if >= 4.6, use -Ofast, otherwise -O3.
sed -i'' -e 's/"-Ofast"/"-O3"/g' setup.py
$PYTHON setup.py install --prefix=$PREFIX
