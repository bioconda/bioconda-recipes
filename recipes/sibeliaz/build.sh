#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|VERSION 3.0|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|CMAKE_CXX_STANDARD 11|CMAKE_CXX_STANDARD 14|' CMakeLists.txt
rm -rf *.bak

if [[ `uname -s` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DNO_DEPENDENCIES=True \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    "${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
