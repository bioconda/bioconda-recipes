#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/bin"

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

#link include and lib folders to allow using htslib
ln -s $PREFIX/include htslib/include
ln -s $PREFIX/lib htslib/lib

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH

#build (enable debug info by adding '-Wall -d')
mkdir build
cd build
qmake CONFIG-=debug CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT QMAKE_CXX="$CXX" QMAKE_CC="$CC" QMAKE_CFLAGS="$CFLAGS" QMAKE_CXXFLAGS="$CXXFLAGS" QMAKE_LIBDIR+="$PREFIX/lib" QMAKE_RPATHLINKDIR+="${PREFIX}/lib/" ../src/tools.pro
make -j"${CPU_COUNT}"
cd ..

#remove test files from bin folder
rm -rf bin/out bin/cpp*-TEST bin/tools-TEST

#deploy (lib)
mv bin/libcpp* $PREFIX/lib/

#deploy (bin)
install -v -m 0755 bin/* "$PREFIX/bin"
