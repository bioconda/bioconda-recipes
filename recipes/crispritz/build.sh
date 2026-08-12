#!/bin/bash

make -f Makefile_conda \
    CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}" \
    BUILD_PREFIX="${PREFIX}"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crispritz"
chmod -R 700 .
cp crispritz.py "${PREFIX}/bin/"
cp -R \
    buildTST \
    searchTST \
    searchBruteForce \
    sourceCode/Python_Scripts \
    "${PREFIX}/opt/crispritz/"
# Install the compiled (fast) enricher in BOTH places crispritz.py
# _enricher_command() checks: a binary named 'enricher' on PATH, and one beside
# the copied Python_Scripts/Enrichment/. Makefile_conda builds it at the repo
# root (not inside Python_Scripts), so it must be copied in explicitly; without
# it crispritz silently falls back to the ~15x slower pure-Python enricher.py.
cp enricher "${PREFIX}/bin/enricher"
cp enricher "${PREFIX}/opt/crispritz/Python_Scripts/Enrichment/enricher"
