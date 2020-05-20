#!/bin/sh

export BOOST_ROOT="${PREFIX}"

mkdir build
cd build
../src/configure --prefix=${PREFIX}
make
make install
