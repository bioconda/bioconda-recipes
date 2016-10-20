#!/bin/bash

mkdir -p $PREFIX/bin


cd $SRC_DIR/codebase
wget -O seqlib.tar.gz https://github.com/isovic/seqlib/archive/6c00d87.tar.gz
tar -xvf seqlib.tar.gz -C seqlib --strip-components 1
wget -O argumentparser.tar.gz https://github.com/isovic/argumentparser/archive/d0dae52.tar.gz
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

