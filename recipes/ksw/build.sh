#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -g -Wall -Wno-unused-function -Wno-incompatible-pointer-types"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

case $(uname -m) in
    aarch64|arm64)
        export EXTRA_ARGS="aarch64=1" ;;
    *)
        export EXTRA_ARGS="" ;;
esac

make "${EXTRA_ARGS}" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    INCLUDES="${PREFIX}/include" \
    PREFIX="${PREFIX}/bin" \
    PKG_VERSION="${PKG_VERSION}" \
    -j1

make install
