#!/bin/sh

export CXX=${PREFIX}/bin/g++


make boost-fix=1

mkdir -p $PREFIX/bin
cp spingo spindex $PREFIX/bin
cp ../dist/*.py $PREFIX/bin
chmod a+x $PREFIX/bin/*.py
