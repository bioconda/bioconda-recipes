#!/bin/bash

# Needed for building utils dependency
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

mkdir -p "${PREFIX}/bin"
mkdir -p build
cd build || exit 1
cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_C_FLAGS="${CFLAGS} -O3 -lrt" \
  "${CONFIG_ARGS}"
cmake --build . --target install -j "${CPU_COUNT}" -v

# Needed to run asset builder
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/build_biscuit_QC_assets.pl
