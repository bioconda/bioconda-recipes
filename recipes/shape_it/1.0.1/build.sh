#!/bin/sh

cmake . -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_STANDARD=98
make
make install

