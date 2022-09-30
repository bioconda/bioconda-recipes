#!/bin/sh

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} .
make
make install
