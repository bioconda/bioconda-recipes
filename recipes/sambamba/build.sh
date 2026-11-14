#!/bin/bash

set -xe

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	# LDC <= 1.40 links a druntime that segfaults at startup on macOS >= 15.4
	# (dlang/dmd#21126, ldc-developers/ldc#4899); the fix ships from LDC 1.41.
	wget https://github.com/ldc-developers/ldc/releases/download/v1.43.0/ldc2-1.43.0-osx-arm64.tar.xz
	tar -xf ldc2-1.43.0-osx-arm64.tar.xz
	export PATH="${SRC_DIR}/ldc2-1.43.0-osx-arm64/bin:${PATH}"
	export LIBRARY_PATH="${SRC_DIR}/ldc2-1.43.0-osx-arm64/lib"
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
