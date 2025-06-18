#!/bin/bash

set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "${target_platform}" == "linux-"* ]]; then
  export CFLAGS="${CFLAGS} -O3 -fPIC"
else
  export CFLAGS="${CFLAGS} -O3"
fi

export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak \
  -e 's/" v."superpose_version" from "superpose_date" built"/" v.%s from %s built"/' \
  -e 's/,ssm::MAJOR_VERSION/,superpose_version, superpose_date, ssm::MAJOR_VERSION/' \
  -e 's/" Superpose v."superpose_version" from "superpose_date" "/" Superpose v.%s from %s "/' \
  -e $'s/------\\n\\n"/------\\n\\n",superpose_version, superpose_date/' \
  superpose.cpp

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

autoreconf -ifv
./configure \
    --prefix="${PREFIX}" \
    --enable-ccp4 \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-silent-rules \
    --disable-option-checking \
    --verbose \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}" V=1
make install V=1
