#!/bin/bash

#wget http://www.microbeatlas.org/mapref/mapref-2.2b.tar.gz
#tar -Cdata -xvzf mapref-2.2b.tar.gz && mv data/mapref-2.2b/* data/ && rmdir data/mapref-2.2b && touch data/mapref-2.2b.fna

touch data/mapref-3.0.fna data/mapref-3.0.fna.mscluster data/mapref-3.0.fna.ncbitax data/mapref-3.0.fna.otutax data/mapref-3.0.gold.fna data/mapref-3.0.gold.fna.mscluster data/mapref-3.0.gold.fna.ncbitax data/mapref-3.0.fna.otutax.97.ncbitax data/mapref-3.0.otus.info
./bootstrap
./configure --prefix=$PREFIX CXXFLAGS="-O2 -I$CONDA_PREFIX/include"
make
make install
