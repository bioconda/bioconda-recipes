#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

sed -i.bak 's|VERSION 3.0|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|VERSION 2.8|VERSION 3.5|' src/libqes/CMakeLists.txt

if [[ "$(uname -s)" == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

mkdir build && cd build
cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli -DNO_OPENMP=yes \
    "${CONFIG_ARGS}"

if [[ "$(uname -s)" == "Linux" ]]; then
    make all test install -j"${CPU_COUNT}"
else
    # The python-based integration test expects linux so fails on OSX
    make all install -j"${CPU_COUNT}"
fi
