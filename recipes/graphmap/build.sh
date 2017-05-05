#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin


cd $SRC_DIR/codebase
wget -O seqlib.tar.gz https://github.com/isovic/seqlib/archive/55737bb85100af27c8ae761681e169792dcce115.tar.gz
tar -xvf seqlib.tar.gz -C seqlib --strip-components 1
wget -O argparser.tar.gz https://github.com/isovic/argparser/archive/72af9764acefbcc92ff76e3aba8a83d9a3e33671.tar.gz
tar -xvf argparser.tar.gz -C argumentparser --strip-components 1

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
