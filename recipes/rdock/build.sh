#!/bin/bash

set -euo pipefail

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -std=c++14"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak -e "s|INCLUDE\s*:=|INCLUDE := -I${PREFIX}/include |" \
           -e "s|LIB_DEPENDENCIES\s*:=\s*-lpopt|LIB_DEPENDENCIES := -L${PREFIX}/lib -lpopt|" \
           Makefile

install -d ${PREFIX}/share/rDock
cp -r lib data tests ${PREFIX}/share/rDock
rm lib/*
make -j${CPU_COUNT}
PREFIX=${PREFIX} make install

mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/activate.sh
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/deactivate.sh
