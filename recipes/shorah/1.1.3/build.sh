#!/bin/bash

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
./configure --prefix="${PREFIX}" PYTHON="${PYTHON}"
make
make install
