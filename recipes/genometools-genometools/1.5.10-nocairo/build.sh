#!/bin/bash

set -e -o pipefile -x

make cairo=no verbose=yes
export prefix=$PREFIX
make cairo=no verbose=yes install 

cd gtpython
$PYTHON setup.py install

