#!/bin/bash

set -eo pipefail

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

hash -r

case $(uname -m) in
    aarch64 | arm64)
	cp -rfv ${RECIPE_DIR}/sse2neon.h ${SRC_DIR}
        cmake -DCMAKE_BUILD_TYPE=Release -S . -B build_cmake
        cmake --build build_cmake -j"${CPU_COUNT}"
        install -v -m 0755 build_cmake/PretextGraph "${PREFIX}/bin"
        ;;
    *)
        if [[ `uname` == "Darwin" ]]; then
            meson setup --buildtype=release --prefix="${PREFIX}" --strip --unity on builddir
        else
            env CC="${CC}" CXX="${CXX}" meson setup --buildtype=release --prefix="${PREFIX}" --strip --unity on builddir
        fi

        cd builddir
        meson compile
        meson test
        meson install
        ;;
esac
