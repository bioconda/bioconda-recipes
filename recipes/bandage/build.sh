#!/bin/bash
set -ex

mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
if [[ `uname` == "Darwin" ]]; then
  ln -sf ${CC} ${BUILD_PREFIX}/bin/clang
	ln -sf ${CXX} ${BUILD_PREFIX}/bin/clang++
else
	ln -sf ${CC} ${BUILD_PREFIX}/bin/gcc
	ln -sf ${CXX} ${BUILD_PREFIX}/bin/g++
fi
export PATH=$BUILD_PREFIX/bin/:$PATH

# Run qmake to generate a Makefile
qmake Bandage.pro QMAKE_CXX="$CXX" QMAKE_CC="$CC" QMAKE_CFLAGS="$CFLAGS" QMAKE_CXXFLAGS="$CXXFLAGS"

# fix the makefile
sed -i.bak "s/isystem/I/" Makefile
rm -rf *.bak
# Build the program
make -j"${CPU_COUNT}"

# Install
if [[ `uname` == "Darwin" ]]; then
	install -v -m 0755 Bandage.app/Contents/MacOS/Bandage ${PREFIX}/bin
else
	install -v -m 0755 Bandage ${PREFIX}/bin
fi
