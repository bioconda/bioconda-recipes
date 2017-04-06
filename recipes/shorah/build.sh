#!/bin/bash

# replace python shebangs
for j in src/scripts/*.py.in; do
	sed -i.bak '1 s|^.*$|#!/usr/bin/env python2|g' "${j}"
done

./configure --prefix="${PREFIX}" PYTHON="${PYTHON}"
make
make install
