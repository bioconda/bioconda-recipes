#!/bin/bash
set -euo pipefail
set -x

#link global include/lib folders, where htslib is installed by conda, into ngs-bits htslib folder
ln -s $PREFIX/include htslib/include
ln -s $PREFIX/lib htslib/lib

# Ensure pkg-config can find libxml2 (conda-forge installs .pc into $BUILD_PREFIX)
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"
pkg-config --cflags libxml-2.0
pkg-config --libs libxml-2.0

export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

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
esac

# Ensure qmake uses correct compiler
export QMAKE_CXX="${CXX}"
export QMAKE_CC="${CC}"

#check qmake version
qmake --version

#build (enable debug info by adding '-Wall -d')
mkdir build
cd build
qmake CONFIG-=debug CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT QMAKE_CXX="$CXX" QMAKE_CC="$CC" QMAKE_CFLAGS="$CFLAGS" QMAKE_CXXFLAGS="$CXXFLAGS" QMAKE_LIBDIR+="${PREFIX}/lib" QMAKE_RPATHLINKDIR+="${PREFIX}/lib/" ../src/tools.pro
make -j"${CPU_COUNT}"
cd ..

#remove test files from bin folder
rm -rf bin/out bin/cpp*-TEST bin/tools-TEST

#deploy (lib)
install -m 0755 bin/libcpp* "${PREFIX}/lib/"

#deploy (bin)
install -v -m 0755 bin/* "${PREFIX}/bin"
