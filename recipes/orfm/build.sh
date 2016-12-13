#!/bin/bash

# fix automake
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/automake

cd $SRC_DIR/ext
wget -O seqtk.tar.gz https://github.com/lh3/seqtk/archive/d3b53c9.tar.gz
tar -xvf seqtk.tar.gz -C seqtk --strip-components 1
cd ..

mkdir -p $PREFIX/bin
autoreconf --install
./configure
make
mv orfm  $PREFIX/bin
