#!/bin/bash
set -euo pipefail

# NOTE: The upstream release tarball ships a makefile that hard-codes `g++`
# and has no install target, neither of which works in the conda build
# environment (where the compiler is ${CXX} and there is no `g++`). We
# therefore compile directly here, honouring the conda-provided compiler and
# ${CPPFLAGS}/${CXXFLAGS}/${LDFLAGS}, instead of calling `make`.

bin="MitoGeneExtractor-v${PKG_VERSION}"

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} -std=c++11 -O2 \
    -I. -Itclap-1.2.5/include \
    MitoGeneExtractor.cpp \
    global-types-and-parameters_MitoGeneExtractor.cpp \
    exonerate_wrapper_and_parser.cpp \
    ${LDFLAGS} \
    -o "${bin}"

# Install the versioned binary plus a stable "MitoGeneExtractor" command.
mkdir -p "${PREFIX}/bin"
cp "${bin}" "${PREFIX}/bin/"
ln -s "${bin}" "${PREFIX}/bin/MitoGeneExtractor"
