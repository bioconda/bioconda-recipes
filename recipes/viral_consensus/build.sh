#!/bin/bash

sed -i 's/git submodule/#git submodule/g' Makefile
git clone --recurse-submodules https://github.com/samtools/htslib.git
make
if [ ! -d "$PREFIX/bin" ]; then
    mkdir $PREFIX/bin;
    export PATH=$PREFIX/bin:$PATH;
fi
cp viral_consensus $PREFIX/bin/
