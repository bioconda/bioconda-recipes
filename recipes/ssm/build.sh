#!/bin/bash

set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

autoreconf -if

sed -i.bak \
  -e 's/" v."superpose_version" from "superpose_date" built"/" v.%s from %s built"/' \
  -e 's/,ssm::MAJOR_VERSION/,superpose_version, superpose_date, ssm::MAJOR_VERSION/' \
  -e 's/" Superpose v."superpose_version" from "superpose_date" "/" Superpose v.%s from %s "/' \
  -e $'s/------\\n\\n"/------\\n\\n",superpose_version, superpose_date/' \
  superpose.cpp

if [[ "${target_platform}" == "linux-"* ]]; then
  export CFLAGS="${CFLAGS} -fPIC"
elif [[ "${target_platform}" == "osx-"* ]]; then
  sed -i.bak -e 's/\${wl}-flat_namespace//g' \
    -e 's/\${wl}-undefined \${wl}suppress/-undefined dynamic_lookup/g' \
    configure
fi

./configure \
    --prefix="${PREFIX}" \
    --enable-ccp4 \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-silent-rules \
    --disable-option-checking \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}"
make install
