#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

case "$(uname)"  in
    Linux)
        # use gcc on linux
        ./waf configure \
            --check-c-compiler=gcc \
            --check-cxx-compiler=g++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
    Darwin)
        # patch waf script on macOS (remember: different sed version)
        # Update line 18 (CXXFLAGS) to add -stdlib=libc++ and -std=c++11
        sed -i '' "18s/\[/['-stdlib=libc++', '-std=c++11', /" wscript

        ./waf configure \
            --check-c-compiler=clang \
            --check-cxx-compiler=clang++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
esac

# release mode is important
./waf build --mode=release install

# run unit tests after building
if ./build/test/unit/test_bgen | grep -q "All tests passed"; then
  exit 0
else
  exit 1
fi
