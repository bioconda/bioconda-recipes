#!/bin/bash

${CXX} -I $PREFIX/include/bamtools -I./ -L $PREFIX/lib -o ngs_disambiguate dismain.cpp -lz -lbamtools
mkdir -p $PREFIX/bin
cp ngs_disambiguate $PREFIX/bin
