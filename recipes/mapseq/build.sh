#!/bin/bash

#wget http://www.microbeatlas.org/mapref/mapref-2.2b.tar.gz
#tar -Cdata -xvzf mapref-2.2b.tar.gz && mv data/mapref-2.2b/* data/ && rmdir data/mapref-2.2b && touch data/mapref-2.2b.fna

touch data/mapref-2.2b.fna data/mapref-2.2b.fna.mscluster data/mapref-2.2b.fna.ncbitax data/mapref-2.2b.fna.otutax data/mapref-2.2b.gold.fna data/mapref-2.2b.gold.fna.mscluster data/mapref-2.2b.gold.fna.ncbitax data/mapref-2.2b.fna.otutax.97.ncbitax
./bootstrap
./configure --prefix=$PREFIX CXXFLAGS="-O2 -I$CONDA_PREFIX/include"
make
make install
