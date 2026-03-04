#!/bin/bash
set -eu -o pipefail

# Add include paths for filo's internal headers (gzstream.h, tabFile.h, etc.)
# which are referenced with angle brackets in the source files.
FILO_INCLUDES="-I${SRC_DIR}/src/common/gzstream -I${SRC_DIR}/src/common/tabFile -I${SRC_DIR}/src/common/fileType -I${SRC_DIR}/src/common/version"

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -Wall -O2 ${FILO_INCLUDES}" LIBS="-lz -L${PREFIX}/lib"

# Install binaries
mkdir -p "${PREFIX}/bin"
cp bin/stats "${PREFIX}/bin/"
cp bin/groupBy "${PREFIX}/bin/"
cp bin/shuffle "${PREFIX}/bin/filo-shuffle"
