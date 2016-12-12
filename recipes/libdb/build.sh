#!/bin/bash

cd build_unix
../dist/configure --prefix=$PREFIX --enable-compat185 --enable-shared --disable-static --enable-cxx
make
make install
