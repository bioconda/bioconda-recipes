#!/bin/sh

cmake . -DCMAKE_INSTALL_PREFIX="$PREFIX" -DOPENBABEL2_INCLUDE_DIRS="$PREFIX/include/openbabel-2.0" -DOPENBABEL2_LIBRARIES="$PREFIX/lib/libopenbabel.so"
make
make install
