#!/bin/bash

mkdir b2 && cd b2

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S .. -B . \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DBUILD_PYTHON_INTERFACE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_LIBRARY=ON \
  -DPYTHON_VERSION=$(python -c 'import platform; print(platform.python_version())') \
  -DPython_ROOT_DIR="${PREFIX}/bin" \
  -DBUILD_PYTHON_DOCS=ON \
  -DBoost_USE_STATIC_LIBS=OFF \
  -DWITH_AVX=OFF \
  -G Ninja \
  "${CONFIG_ARGS}"

# On some platforms (notably aarch64 with Drone) builds can fail due to
# running out of memory. If this happens, try the build again; if it
# still fails, restrict to one core.
ninja install -k 0 || ninja install -k 0 || ninja install -j ${CPU_COUNT}

# Copy programs to bin
chmod 0755 $SRC_DIR/bin/*
cp -f $SRC_DIR/bin/* $PREFIX/bin
