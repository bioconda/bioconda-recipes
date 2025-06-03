#!/bin/bash

set -xe

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	wget https://github.com/ldc-developers/ldc/releases/download/v1.40.0/ldc2-1.40.0-osx-arm64.tar.xz
	tar -xf ldc2-1.40.0-osx-arm64.tar.xz
	export PATH="${SRC_DIR}/ldc2-1.40.0-osx-arm64/bin:${PATH}"
	export LIBRARY_PATH="${SRC_DIR}/ldc2-1.40.0-osx-arm64/lib-ios-arm64"
	export DYLD_LIBRARY_PATH="${PREFIX}/lib:${DYLD_LIBRARY_PATH}"
fi

if [[ "${OS}" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

# Running `make check` recompiles as an unoptimised binary so must be done prior to release compile
make -j"${CPU_COUNT}" check CC="${CC}"

make -j"${CPU_COUNT}" release CC="${CC}" LIBRARY_PATH="${LIBRARY_PATH}"
make install prefix="${PREFIX}" CC="${CC}"

# The binaries are versioned for some reason
mv ${PREFIX}/bin/sambamba-* ${PREFIX}/bin/sambamba
chmod 0755 ${PREFIX}/bin/sambamba
