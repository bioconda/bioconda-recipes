#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

# Refer to https://github.com/rlabduke/reduce/issues/60 for `-DHET_DICTIONARY` and `-DHET_DICTOLD` flags
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DHET_DICTIONARY="${PREFIX}/reduce_wwPDB_het_dict.txt" \
  -DHET_DICTOLD="${PREFIX}/reduce_get_dict.txt" \
  "${CONFIG_ARGS}"
cmake --build build/ --target install -j "${CPU_COUNT}"
