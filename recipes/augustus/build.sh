#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"

make -C auxprogs/filterBam/src BAMTOOLS=${PREFIX}/include/bamtools COMPGENEPRED=true
make -C BAMTOOLS=${PREFIX}/include/bamtools COMPGENEPRED=true

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config

sed -i 's/#!\/usr\/bin\/perl/#!\/usr\/bin\/env perl/g' scripts/*
sed -i 's/ perl -w$/ perl/' scripts/*

mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/bin/
mv config/* $PREFIX/config/
