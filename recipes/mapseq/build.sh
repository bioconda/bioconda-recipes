#!/bin/bash

#wget http://www.microbeatlas.org/mapref/mapref-2.2b.tar.gz
#tar -Cdata -xvzf mapref-2.2b.tar.gz && mv data/mapref-2.2b/* data/ && rmdir data/mapref-2.2b && touch data/mapref-2.2b.fna

touch data/mapref-2.2b.fna
./bootstrap
./configure --prefix=$PREFIX CXXFLAGS="-O2 -I$CONDA_PREFIX/include"
make
make install
