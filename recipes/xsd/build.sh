#!/bin/bash

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations -Wno-terminate -Wno-deprecated"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname -s` == "Darwin" ]]; then
  mv libxsd-frontend/version libxsd-frontend/VERSION
  export CXXFLAGS="${CXXFLAGS} -O3 -std=libc++"
else
  export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
fi

make CC="${CC}" CXX="${CXX}" AR="${AR}" RANLIB="${RANLIB}" CPPFLAGS="${CPPFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install_prefix="${PREFIX}" install
