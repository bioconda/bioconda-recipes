#!/bin/sh
set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"

make
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config

sed -i 's/#!\/usr\/bin\/perl/#!\/usr\/bin\/env perl/g' scripts/*
sed -i 's/ perl -w$/ perl/' scripts/*

mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/bin/
mv config/* $PREFIX/config/

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export AUGUSTUS_CONFIG_PATH=$PREFIX/config/" > $PREFIX/etc/conda/activate.d/augustus-confdir.sh
chmod a+x $PREFIX/etc/conda/activate.d/augustus-confdir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset AUGUSTUS_CONFIG_PATH" > $PREFIX/etc/conda/deactivate.d/augustus-confdir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/augustus-confdir.sh
