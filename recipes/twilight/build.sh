#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

# Build
mkdir -p "${PREFIX}/bin"

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  CONFIG_ARGS="${CONFIG_ARGS} -DUSE_CUDA=ON"
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
  ${CONFIG_ARGS} -Wno-dev -Wno-deprecated --no-warn-unused-cli

cmake --build build --clean-first -j "${CPU_COUNT}"
install -v -m 0755 bin/twilight ${PREFIX}/bin
