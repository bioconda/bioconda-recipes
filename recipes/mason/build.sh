#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case $(uname -m) in
    aarch64)
    export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
    ;;
    arm64)
    export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
    ;;
    x86_64)
    export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
    ;;
    *)
    ;;
esac

if [[ "$(uname -s)" == "Darwin" ]]; then
    export CONFIG_ARGS=(
        -DCMAKE_FIND_FRAMEWORK=NEVER
        -DCMAKE_FIND_APPBUNDLE=NEVER
    )
else
    export CONFIG_ARGS=()
fi

cmake -S . \
      -B build \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER="${CXX}" \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DSEQAN_BUILD_SYSTEM=APP:mason2 \
      "${CONFIG_ARGS[@]}"

ninja -C build -j "${CPU_COUNT}"
ninja -C build install
