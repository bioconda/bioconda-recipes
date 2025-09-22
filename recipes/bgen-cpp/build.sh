#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS:-} -std=c++11 -stdlib=libc++ -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

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
        export CC=clang-17
        export CXX=clang++
        ./waf configure \
            --check-c-compiler clang \
            --check-cxx-compiler clang++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
esac

./waf build install
