#!/bin/bash
cd global-1 && \
./configure --prefix=$PREFIX --bindir=$PREFIX/bin --libdir=$PREFIX/lib && \
make -j && \
make install-special && \
cd $PREFIX/bin && \
tar -xzf TransDecoder-v5.7.1a.tar.gz && \
rm -f  TransDecoder-v5.7.1a.tar.gz
