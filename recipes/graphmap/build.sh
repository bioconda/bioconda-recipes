#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin


cd $SRC_DIR/codebase
wget -O seqlib.tar.gz https://github.com/isovic/seqlib/archive/1d23fd0.tar.gz
tar -xvf seqlib.tar.gz -C seqlib --strip-components 1
wget -O argumentparser.tar.gz https://github.com/isovic/argumentparser/archive/72af976.tar.gz
tar -xvf argumentparser.tar.gz -C argumentparser --strip-components 1

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
