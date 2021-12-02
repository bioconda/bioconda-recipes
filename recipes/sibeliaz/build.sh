#!/bin/bash

mkdir build 
cd build


cmake \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=11 \
    -DNO_DEPENDENCIES=True \
    ..

make

install -d "${PREFIX}/bin"
install \
    SibeliaZ-LCB/sibeliaz-lcb \
    ../SibeliaZ-LCB/sibeliaz \
    "${PREFIX}/bin/"

cd ..
