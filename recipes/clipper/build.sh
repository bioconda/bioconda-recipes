#!/bin/bash

set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

pushd fftw2

# # On macOS/ARM add --build hack to configure
# CONFIG_ARGS=( \
#   --prefix="${PREFIX}/fftw2" \
#   --enable-shared \
#   --enable-float \
#   --disable-static \
# 	--disable-debug \
# 	--disable-dependency-tracking \
# 	--enable-silent-rules \
# 	--disable-option-checking \
# )
# if [[ "${target_platform}" == "osx-arm64" ]]; then
#   BUILD_HOST="arm-apple-$(uname | tr '[:upper:]' '[:lower:]')$(uname -r | cut -d. -f1)"
#   CONFIG_ARGS+=( --build="${BUILD_HOST}" )
# fi

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
