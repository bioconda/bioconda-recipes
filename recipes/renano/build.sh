#! /bin/bash
mkdir -p $PREFIX/bin
cd renano

sed -i.bak 's/CXX *=/CXX ?=/; s/CXXFLAGS *=/CXXFLAGS +=/' Makefile

# Work around "unknown type name 'mach_port_t'" error
if [ x"$(uname)" == x"Darwin" ]; then
  CXXFLAGS="$CXXFLAGS -D_DARWIN_C_SOURCE"
  CPPFLAGS="$CPPFLAGS -D_DARWIN_C_SOURCE"
  export CXXFLAGS CPPFLAGS
fi


# export CPATH=${PREFIX}/include
# export CXXPATH=${PREFIX}/include
# export CFLAGS="$CFLAGS -I$PREFIX/include"
# export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
make INCLUDES="-I$PREFIX/include -L$PREFIX/lib" CFLAGS="-fopenmp -std=c++11 -O3 -march=native -fstrict-aliasing -ffast-math -fomit-frame-pointer -Wall"
cp renano $PREFIX/bin
