#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

case "$(uname)"  in
    Linux)
        echo "Patching Linux build script"
        # patch waf script on Linux
        # force gcc to use C11 plus GNU extensions
        sed -i "15s/\(\s*cfg\.env\.CXXFLAGS *= *\[\)/\1'-std=gnu++11', /" wscript
        sed -i "16s/\(\s*cfg\.env\.CFLAGS *= *\[\)/\1'-std=gnu11', /" wscript

        ./waf configure \
            --check-c-compiler=gcc \
            --check-cxx-compiler=g++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
    Darwin)
        echo "Patching macOS build script"
        # patch waf script on macOS (remember: different sed version)
        # force clang to use C11 standard
        sed -i '' "15s/\(\s*cfg\.env\.CXXFLAGS *= *\[\)/\1'-stdlib=libc++', '-std=c++11', /" wscript
        sed -i '' "16s/\(\s*cfg\.env\.CFLAGS *= *\[\)/\1'-std=c11', /" wscript

        ./waf configure \
            --check-c-compiler=clang \
            --check-cxx-compiler=clang++ \
            --prefix=${PREFIX} \
            --bindir=${PREFIX}/bin \
            --libdir=${PREFIX}/lib \
            --jobs=${CPU_COUNT}
        ;;
esac

./waf build --mode=release install

# run unit tests after building
if ./build/test/unit/test_bgen | grep -q "All tests passed"; then
  exit 0
else
  exit 1
fi
