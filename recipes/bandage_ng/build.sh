#!/bin/bash
set -ex

mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -O3 -Wno-macro-redefined"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ $(uname) == "Linux" ]]; then
  export CONFIG_ARGS="-DFEATURE_egl=ON -DFEATURE_eglfs=ON"
else
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS" \
  -DEGL_INCLUDE_DIR:PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/include" \
  -DEGL_LIBRARY:FILEPATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libEGL.so.1" \
  -DOPENGL_egl_LIBRARY:FILEPATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libEGL.so.1" \
  -DEGL_opengl_LIBRARY:FILEPATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so" \
  -DOPENGL_opengl_LIBRARY:FILEPATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so" \
  -DQT_HOST_PATH="${BUILD_PREFIX}" -DQT_HOST_PATH_CMAKE_DIR="${PREFIX}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"

if [[ $(uname) == "Darwin" ]]; then
  ln -sf $PREFIX/bin/BandageNG.app/Contents/MacOS/BandageNG $PREFIX/bin/BandageNG
fi
