#!/bin/bash
set -e -x -o pipefail
mkdir -p $PREFIX/bin

# This is all the makefile does and it's simpler to just recreat it than to patch things
cd V-Phaser-2.0/src
$CXX -fopenmp -O3 -I${PREFIX}/include/ -I${BUILD_PREFIX}/include -I${PREFIX}/include/bamtools -L${PREFIX}/lib *.cpp -o $PREFIX/variant_caller -lbamtools -lz -lpthread

ln -s $PREFIX/bin/variant_caller $PREFIX/bin/vphaser2
