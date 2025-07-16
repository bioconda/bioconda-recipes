#!/bin/bash

mkdir -p "${PREFIX}/bin"

cp -rf ${RECIPE_DIR}/Makefile .

make CC="${CC}" -j"${CPU_COUNT}"
make install
