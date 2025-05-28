#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

ARCH_BUILD=""
case $(uname -m) in
    x86_64) ARCH_BUILD="-DHAVE_SSE4_1=1" ;;
    arm64|aarch64) ARCH_BUILD="-DHAVE_ARM8=1" ;;
esac

if [[ -z "${ARCH_BUILD}" ]]; then
    echo "Invalid architecture"
    exit 1
fi

if [[ `uname` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release -DCHECK_MPI=1 -DHAVE_MPI=1 \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" "${ARCH_BUILD}" "${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/scripts/*.pl
rm -rf ${SRC_DIR}/scripts/*.bak

# Move the `reformat.pl` script to ${PREFIX}/bin to ensure it's available in the PATH
mv ${SRC_DIR}/scripts/reformat.pl ${PREFIX}/bin
