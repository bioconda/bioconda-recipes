#!/bin/bash
set -euo pipefail

# The upstream Makefile uses a plain `gcc` to compile C++ code and links
# libstdc++ explicitly. Override CC with the conda C++ compiler so the
# build picks up conda's sysroot, headers, and runtime libraries correctly.
make CC="${CXX}" CFLAGS="-Wall -std=c++17 ${CXXFLAGS}"

# Install the binary into ${PREFIX}/bin
mkdir -p "${PREFIX}/bin"
cp restrander "${PREFIX}/bin/"

# Install runtime config JSON files. These ship with the source tree and
# are required as the third positional argument when invoking restrander
# (e.g. `restrander in.fq out.fq config/PCB109.json`).
mkdir -p "${PREFIX}/share/restrander/config"
cp config/*.json "${PREFIX}/share/restrander/config/"
