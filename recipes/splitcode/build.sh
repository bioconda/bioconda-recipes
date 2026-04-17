#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_C_FLAGS="${CFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"
