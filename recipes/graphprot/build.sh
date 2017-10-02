#!/bin/bash

# set install paths
BIN=${CONDA_PREFIX}/bin/
LIBEXEC=${CONDA_PREFIX}/libexec/graphprot/
SHARE=${CONDA_PREFIX}/share/graphprot/

# compile EDeN
pushd .
cd EDeN
make clean
make -j 4
popd

# run build tests
pytest

# install
mkdir -p $BIN $LIBEXEC $SHARE
cp GraphProt.pl $BIN
cp bin/* $LIBEXEC -r
cp EDeN/EDeN $LIBEXEC
cp data $SHARE -r
