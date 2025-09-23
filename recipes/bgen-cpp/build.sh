#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS:-} -std=c++11 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

CLANG_VERSION=17

case "$(uname)"  in
    Linux)
        ./waf configure \
            --check-c-compiler=gcc \
            --check-cxx-compiler=g++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
    Darwin)
        # Use an older version of clang for macOS
        export CC=clang-${CLANG_VERSION}
        export CXX=clang++

        if ! clang++ --version | grep -q "clang version ${CLANG_VERSION}"; then
            echo "Error: clang++ ${CLANG_VERSION} required." >&2
            exit 1
        fi

        ./waf configure \
            --check-c-compiler clang \
            --check-cxx-compiler clang++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
esac

./waf build
