#!/bin/env bash
export INCLUDE_PATH="${PREFIX}/include"
export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

wget https://sourceforge.net/projects/osra/files/openbabel-patched/openbabel-2.3.2-patched.tgz
tar -xzf openbabel-2.3.2-patched.tgz
grep -rl 'set(libs ${libs} c)' openbabel-2.3.2-patched | xargs sed -i 's/set(libs ${libs} c)/set(libs ${libs} c m)/g'
cd openbabel-2.3.2-patched
mkdir build && cd build
cmake -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX -DPYTHON_BINDINGS=ON -DMINIMAL_BUILD=ON ../
make -j2
make install
cd ../../

./configure --prefix=$PREFIX \
    --with-gocr-include=$PREFIX/include/gocr/ \
    --with-gocr-lib=$PREFIX/lib/ \
    --with-openbabel-include=$PREFIX/include/openbabel-2.0/ \
    --with-openbabel-lib=$PREFIX/lib \
    --with-graphicsmagick-include=$PREFIX/include/ \
    --with-graphicsmagick-lib=$PREFIX/lib/
make
make install
