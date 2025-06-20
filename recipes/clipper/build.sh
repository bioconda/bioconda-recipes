#!/bin/bash

set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

pushd fftw2

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/fftw2/fftw"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
aclocal
libtoolize --force
automake --add-missing --force-missing
autoconf

./configure \
  --prefix="${PREFIX}/fftw2" \
  --enable-shared \
  --enable-float \
  --disable-static \
  --disable-debug \
  --disable-dependency-tracking \
  --enable-silent-rules \
  --disable-option-checking

make -j"${CPU_COUNT}"
make install
popd

pushd clipper

export CXXFLAGS="${CXXFLAGS} -g -O2 -fno-strict-aliasing -Wno-narrowing"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/fftw2/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/fftw2/include"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/
autoreconf -if

# Fix pkg-config name mismatch
sed -i.bak 's|libccp4c|ccp4c|g' configure

./configure \
  --prefix="${PREFIX}" \
  --enable-mmdb \
  --enable-ccp4 \
  --enable-cif \
  --enable-minimol \
  --enable-cns \
  --enable-shared \
  --disable-static \
  --disable-debug \
  --disable-dependency-tracking \
  --enable-silent-rules \
  --disable-option-checking

make -j"${CPU_COUNT}"
make install
popd
