#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

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
cp $SRC_DIR/GraphProt.pl ${PREFIX}/bin/
cp -r $SRC_DIR/bin/* ${PREFIX}/libexec/graphprot/
cp $SRC_DIR/EDeN/EDeN ${PREFIX}/libexec/graphprot/
cp -r $SRC_DIR/data ${PREFIX}/share/graphprot/
