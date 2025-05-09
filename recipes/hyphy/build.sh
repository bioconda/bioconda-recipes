#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

case $(uname -m) in
    aarch64|arm64) 
        HYPHY_OPTS=""
        ;;
    *)
        HYPHY_OPTS="-DNOAVX=ON"
        ;;
esac

cmake -S . -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    "${HYPHY_OPTS}" \
    "${CONFIG_ARGS}"
cmake --build . --target HYPHYMPI -j "${CPU_COUNT}"
cmake --build . --target install -j "${CPU_COUNT}"
