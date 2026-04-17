#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
# Add include paths for filo's internal headers (gzstream.h, tabFile.h, etc.)
# which are referenced with angle brackets in the source files.
export FILO_INCLUDES="-I${PREFIX}/include -I${SRC_DIR}/src/common/gzstream -I${SRC_DIR}/src/common/tabFile -I${SRC_DIR}/src/common/fileType -I${SRC_DIR}/src/common/version"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -Wall ${FILO_INCLUDES}" LIBS="-L${PREFIX}/lib -lz"

# Install binaries
install -v -m 0755 bin/stats bin/groupBy "${PREFIX}/bin"
install -v -m 0755 bin/shuffle "${PREFIX}/bin/filo-shuffle"
