#!/bin/bash

set -euo pipefail

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -std=c++14 -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak -e 's|:= $(add|:= -I$(PREFIX)/include $(add|' \
           -e 's|-lpopt -lm|-L$(PREFIX)/lib -lpopt -lm|' \
           -e 's|g++|$(CXX)|' \
           -e 's|-I$(BREW_PREFIX)|-I$(PREFIX)|' \
           -e 's|-L$(BREW_PREFIX)|-L$(PREFIX)|' \
           Makefile
rm -rf *.bak

install -d ${PREFIX}/share/rDock
cp -rf lib data tests ${PREFIX}/share/rDock
rm -f lib/*
make CXX="${CXX}" CXX_EXTRA_FLAGS="-I${PREFIX}/include" PREFIX="${PREFIX}" -j"${CPU_COUNT}"
PREFIX="${PREFIX}" make install

mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
cp -f ${RECIPE_DIR}/activate.sh "${PREFIX}/etc/conda/activate.d/activate.sh"
cp -f ${RECIPE_DIR}/deactivate.sh "${PREFIX}/etc/conda/deactivate.d/deactivate.sh"
