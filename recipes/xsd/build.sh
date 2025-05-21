#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

perl -pi -w -e 's/<version>/"version"/g;' $( grep -rl '<version>' ) libxsd-frontend/version

make CC="${CC}" CXX="${CXX}" AR="${AR}" RANLIB="${RANLIB}" CPPFLAGS="${CPPFLAGS}" CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-terminate -Wno-deprecated" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install_prefix="${PREFIX}" install
