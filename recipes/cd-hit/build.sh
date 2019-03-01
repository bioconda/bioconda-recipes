#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak 's/^CC =$//g' Makefile

#cat > test-openmp.cc <<END
#include <omp.h>
#END

if g++ -o /dev/null -c test-openmp.cc 2>/dev/null
then
  OPENMP_SUPPORTED=yes
else
  OPENMP_SUPPORTED=no
fi

make openmp=$OPENMP_SUPPORTED

mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin
