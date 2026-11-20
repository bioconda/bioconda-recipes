#!/bin/bash

set -euo pipefail

make clean
make -j "${CPU_COUNT}" CXX="${CXX}" CC="${CXX}" FLAGS="${CXXFLAGS}"

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/evaladmix"
cp evalAdmix "${PREFIX}/bin/"
cp visFuns.R "${PREFIX}/share/evaladmix/"
