#!/bin/bash
export CXX=$BUILD_PREFIX/bin/$HOST-c++
export CC=$BUILD_PREFIX/bin/$HOST-cc
export AR=$BUILD_PREFIX/bin/$HOST-ar
export RANLIB=$BUILD_PREFIX/bin/$HOST-ranlib
export CXXFLAGS="${CXXFLAGS} -Wno-register -fPIC"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
sed -i '41s/g++/$(CXX)/' Makefile
mkdir -p $PREFIX/lib $PREFIX/bin $PREFIX/include
make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" PREFIX="$PREFIX"
install *.o $PREFIX/lib/
if [ -f libgffc.so ] ; then
    install *.so $PREFIX/lib/
fi
if [ -f libgffc.dylib ] ; then
    install *.dylib $PREFIX/lib/
fi
install *.h $PREFIX/include/
install *.hh $PREFIX/include/
install gtest $PREFIX/bin/
install threads $PREFIX/bin/
