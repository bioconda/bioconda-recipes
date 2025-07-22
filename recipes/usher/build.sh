#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname -s)" == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

mkdir -p build
pushd build

if [[ "$(uname -m)" == "arm64" ]]; then
    export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
else
    export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

cmake -S .. -B . -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DBOOST_ROOT="${PREFIX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${EXTRA_ARGS}" \
    "${CONFIG_ARGS}"

ninja -j"${CPU_COUNT}"

ls -lh
install -v -m 755 usher* mat* transpose* ripples* compareVCF check_samples_place "${PREFIX}/bin"

popd