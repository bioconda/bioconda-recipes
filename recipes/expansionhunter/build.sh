#!/bin/bash
set -eu -o pipefail

#cd ExpansionHunter
mkdir build
cd build
cmake ..
make
mv ExpansionHunter $PREFIX/bin
