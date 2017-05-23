#!/bin/env bash

wget https://sourceforge.net/projects/osra/files/gocr-patched/gocr-0.50pre-patched.tgz
tar -xzf gocr-0.50pre-patched.tgz
cd gocr-0.50pre-patched/
make install
cd ../


wget https://sourceforge.net/projects/osra/files/openbabel-patched/openbabel-2.3.2-patched.tgz
tar -xzf openbabel-2.3.2-patched.tgz
cd openbabel-2.3.2-patched/
mkdir build
cd build
cmake ../
make -j2
make install
cd ../../

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

./configure --with-tclap-include=$PREFIX/include/ \
    --with-potrace-include=$PREFIX/include/ \
    --with-potrace-lib=$PREFIX/lib/ \
    --with-gocr-include=$PREFIX/include/gocr/ \
    --with-gocr-lib=$PREFIX/lib/ \
    --with-ocrad-include=$PREFIX/include/ \
    --with-ocrad-lib=$PREFIX/lib/ \
    --with-openbabel-include=$PREFIX/include/openbabel-2.0/ \
    --with-openbabel-lib=$PREFIX/lib \
    --with-graphicsmagick-lib=$PREFIX/lib/ \
    --with-graphicsmagick-include=$PREFIX/include/ \
    --prefix=$PREFIX
make all install
