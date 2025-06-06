#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

# use newer config.guess and config.sub that support osx-arm64
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .

mv configure.in configure.ac

# Regenerate configure to fix flat namespace errors on macOS 11+
autoreconf -fvi
./configure --prefix="${PREFIX}" \
    --without-x --disable-debug --disable-dependency-tracking \
    --enable-64 --with-thread CC="${CC}" CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
    CXX="${CXX}"

make -j"${CPU_COUNT}"
make install

${PYTHON} ${RECIPE_DIR}/fix_acd_path.py ${PREFIX}/bin
