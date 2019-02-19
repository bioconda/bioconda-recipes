#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

cd $SRC_DIR/codebase
wget --no-check-certificate -O seqlib.tar.gz https://github.com/isovic/seqlib/archive/d980be7.tar.gz
tar -xvf seqlib.tar.gz -C seqlib --strip-components 1
wget --no-check-certificate -O argumentparser.tar.gz https://github.com/isovic/argumentparser/archive/72af976.tar.gz
tar -xvf argumentparser.tar.gz -C argumentparser --strip-components 1
wget --no-check-certificate -O gindex.tar.gz https://github.com/isovic/gindex/archive/b1fb5ad.tar.gz
tar -xvf gindex.tar.gz -C gindex --strip-components 1

cd $SRC_DIR

if [ "$(uname)" == "Darwin" ]; then
    echo "Installing GraphMap for OSX."
    make mac
    cp bin/Mac/graphmap $PREFIX/bin
else
    echo "Installing GraphMap for UNIX/Linux."
    make
    cp bin/Linux-x64/graphmap $PREFIX/bin
fi
