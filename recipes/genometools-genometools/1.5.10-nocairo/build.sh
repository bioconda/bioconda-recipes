#!/bin/bash

set -e -o pipefail -x

make cairo=no
export prefix=$PREFIX
make cairo=no install 

cd gtpython
$PYTHON setup.py install

