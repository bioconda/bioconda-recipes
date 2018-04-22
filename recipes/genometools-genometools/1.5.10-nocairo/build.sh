#!/bin/bash

set -e -o pipefail -x

make cairo=no verbose=yes
export prefix=$PREFIX
make cairo=no verbose=yes install 

cd gtpython
$PYTHON setup.py install

