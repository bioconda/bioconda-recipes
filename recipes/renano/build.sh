#! /bin/bash
mkdir -p $PREFIX/bin
cd renano

# src/Makefile uses
# > CXX = g++
# > CXXFLAGS = -Wall -fopenmp -O3
# We patch these to add to environment, rather than override
# because we can't get to the `make` call easily.
sed -i.bak 's/CXX *=/CXX ?=/; s/CXXFLAGS *=/CXXFLAGS +=/' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile
CXXFLAGS=""
CPPFLAGS=""
# Work around "unknown type name 'mach_port_t'" error
if [ x"$(uname)" == x"Darwin" ]; then
  CXXFLAGS="$CXXFLAGS -D_DARWIN_C_SOURCE"
  CPPFLAGS="$CPPFLAGS -D_DARWIN_C_SOURCE"
  export CXXFLAGS CPPFLAGS
fi

# export CPATH=${PREFIX}/include
# export CXXPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
echo $CXXFLAGS
echo $LDFLAGS
make
cp renano $PREFIX/bin
