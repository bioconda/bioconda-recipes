#!/bin/bash

# replace python shebangs
for j in src/scripts/*.py.in; do
	sed -i.bak '1 s|^.*$|#!/usr/bin/env python2|g' "${j}"
done

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
./configure --prefix="${PREFIX}" PYTHON="${PYTHON}"
make
make install
