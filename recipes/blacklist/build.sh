#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p $PREFIX/bin/
make
cp Blacklist $PREFIX/bin/

