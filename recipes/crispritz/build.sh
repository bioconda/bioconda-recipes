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

# The enricher is the 4th binary Makefile_conda builds; the published 2.9.0 and 2.9.1
# recipes never installed it, so packaged installs fell back to enricher.py (1.6-1.8x
# slower, the same output). Install it where crispritz.py's _enricher_command() looks,
# PATH first, then beside the reference implementation, as CRISPRitz's own
# conda/build.sh does (meta.yaml's test commands check both).
cp enricher "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/enricher"
cp enricher "${PREFIX}/opt/crispritz/Python_Scripts/Enrichment/enricher"
