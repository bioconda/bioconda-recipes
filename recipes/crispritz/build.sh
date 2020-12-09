#!/bin/bash

make -f Makefile_conda \
    CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}" \
    BUILD_PREFIX="${PREFIX}"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crispritz"
chmod -R 700 .
mv crispritz.py crispritz
cp crispritz "${PREFIX}/bin/"
cp -R \
    buildTST \
    searchTST \
    searchBruteForce \
    sourceCode/Python_Scripts \
    "${PREFIX}/opt/crispritz/"
