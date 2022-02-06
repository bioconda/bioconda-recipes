#!/bin/bash

set -e -o pipefail -x

make cairo=no errorcheck=no
export prefix=$PREFIX
make cairo=no errorcheck=no install 

cd gtpython
$PYTHON setup.py install

