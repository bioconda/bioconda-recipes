#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

sed -i.bak 's/^CC =$//g' Makefile
sed -i.bak 's/^#LDFLAGS.*//g' Makefile
rm -rf *.bak

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' *.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' cd-hit-auxtools/*.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' psi-cd-hit/*.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' usecases/Miseq-16S/*.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' usecases/miRNA-seq/*.pl

rm -rf *.bak
rm -rf cd-hit-auxtools/*.bak
rm -rf psi-cd-hit/*.bak
rm -rf usecases/Miseq-16S/*.bak
rm -rf usecases/miRNA-seq/*.bak

#if [[ "$OSTYPE" == "darwin"* ]]; then
  #Lines below is commented out until fix provided for OPENMP support on OS X for this program
  #CCFLAGS="$CCFLAGS -Wl,-rpath ${PREFIX}/lib -L${PREFIX}/lib -I${PREFIX}/include -fopenmp"
  #sed -i.bak 's/CCFLAGS = -fopenmp/CCFLAGS += -fopenmp/g' Makefile
  #rm -rf *.bak
  #LDFLAGS="$LDFLAGS -stdlib=libc++"

  #make CC="${CXX}" openmp=no MAX_SEQ=1000000 -j"${CPU_COUNT}"
#else
  #make CC="${GXX}" MAX_SEQ=1000000 -j"${CPU_COUNT}"
#fi

make CC="${CXX}" MAX_SEQ=1000000 -j"${CPU_COUNT}"

make install PREFIX="$PREFIX/bin"
