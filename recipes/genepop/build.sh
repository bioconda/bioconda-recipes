#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

cd src
${CXX} -DNO_MODULES -o Genepop GenepopS.cpp -O3 -std=c++14

install -v -m 0755 Genepop "$PREFIX/bin"
