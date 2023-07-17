#!/bin/bash
set -xeuo pipefail
./configure --prefix=$PREFIX
make
make install
ln -s $PREFIX/bin/pear $PREFIX/bin/pearRM
