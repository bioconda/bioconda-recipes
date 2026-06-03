#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

if [[ "${target_platform}" == osx-* ]]; then
    export CPPFLAGS="${CPPFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

make COMPILER="${CXX}" \
    LDFLAGS="${LDFLAGS}" \
    INC="${CPPFLAGS} -Iexternal/CLI11/include/CLI -Iexternal/parallel-hashmap -Iexternal/boost/libs/math/include" \
    -j"${CPU_COUNT}"

install -v -m 0755 krepp "$PREFIX/bin"
