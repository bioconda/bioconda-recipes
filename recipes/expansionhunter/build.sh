#!/bin/bash
set -eu -o pipefail

#cd ExpansionHunter
mkdir build
cd build
cmake  -DBOOST_ROOT=$PREFIX  ..
make
mv ExpansionHunter $PREFIX/bin
