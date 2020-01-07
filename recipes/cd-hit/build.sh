#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

sed -i.bak 's/^CC =$//g' Makefile
sed -i.bak 's/^#LDFLAGS.*//g' Makefile


if [[ "$OSTYPE" == "darwin"* ]]; then
  #Lines below is commented out until fix provided for OPENMP support on OS X for this program
 
  #CCFLAGS="$CCFLAGS -Wl,-rpath ${PREFIX}/lib -L${PREFIX}/lib -I${PREFIX}/include -fopenmp"
  #sed -i.bak 's/CCFLAGS = -fopenmp/CCFLAGS += -fopenmp/g' Makefile
  LDFLAGS="$LDFLAGS -stdlib=libc++"
  
  make CC=clang++ openmp=no
else
  make CC=$GXX
fi

mkdir -p $PREFIX/bin 
make install PREFIX=$PREFIX/bin 
