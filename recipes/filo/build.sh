#!/bin/bash
set -eu -o pipefail

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include" LIBS="-lz -L${PREFIX}/lib"

# Install binaries
mkdir -p "${PREFIX}/bin"
cp bin/stats "${PREFIX}/bin/"
cp bin/groupBy "${PREFIX}/bin/"
cp bin/shuffle "${PREFIX}/bin/filo-shuffle"
