#!/bin/bash
set -e -o pipefail -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

make cairo=yes 64bit=yes errorcheck=no -j"${CPU_COUNT}"
make prefix="${PREFIX}" cairo=yes 64bit=yes errorcheck=no install

cd gtpython

$PYTHON setup.py install
