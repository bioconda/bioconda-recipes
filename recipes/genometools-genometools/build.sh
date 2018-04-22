#!/bin/bash

set -e -o pipefail -x

make 
export prefix=$PREFIX
make install 

cd gtpython
$PYTHON setup.py install

