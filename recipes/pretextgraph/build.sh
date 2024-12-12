#!/bin/bash

set -xeo pipefail

mkdir -p "${PREFIX}bin"

case $(uname -m) in
    aarch64 | arm64)
        cmake -DCMAKE_BUILD_TYPE=Release -S . -B build_cmake
        cmake --build build_cmake -j"${CPU_COUNT}"
        install -m 0755 build_cmake/PretextGraph "${PREFIX}/bin"
        ;;
    *)
        if [ `uname` == Darwin ]; then
            meson setup --buildtype=release --prefix=$PREFIX --unity on builddir
        else
            env CC=clang CXX=clang++ meson setup --buildtype=release --prefix=$PREFIX --unity on builddir
        fi

        cd builddir
        meson compile
        meson test
        meson install
        ;;
esac


