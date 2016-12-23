#!/bin/bash


#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib/bamtools"

#make -C auxprogs/filterBam/src BAMTOOLS=${PREFIX}/include/bamtools COMPGENEPRED=true
export C_INCLUDE_PATH=$PREFIX/include 
export LIBRARY_PATH=$PREFIX/lib 
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"


make COMPGENEPRED=true

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config

sed -i 's/#!\/usr\/bin\/perl/#!\/usr\/bin\/env perl/g' scripts/*
sed -i 's/ perl -w$/ perl/' scripts/*

mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/bin/
mv config/* $PREFIX/config/
