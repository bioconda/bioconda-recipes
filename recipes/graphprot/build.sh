#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

# set install paths
BIN=${PREFIX}/bin/
LIBEXEC=${PREFIX}/libexec/graphprot/
SHARE=${PREFIX}/share/graphprot/

# compile EDeN
pushd .
cd EDeN
make clean
make CC="${CC}" CXX="${CXX}"
popd

# run build tests
pytest

# install
mkdir -p $BIN $LIBEXEC $SHARE
cp $SRC_DIR/GraphProt.pl $BIN
cp $SRC_DIR/bin/* $LIBEXEC -r
cp $SRC_DIR/EDeN/EDeN $LIBEXEC
cp $SRC_DIR/data $SHARE -r
