#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
      export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
      export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_CXX_COMPILER="${CXX}" \
      -DZLIB_ROOT="${PREFIX}" \
      "${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_CXX_COMPILER="${CXX}" \
      -DBUILD_SHARED_LIBS="TRUE" \
      -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
      -DZLIB_ROOT="${PREFIX}" \
      "${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"
