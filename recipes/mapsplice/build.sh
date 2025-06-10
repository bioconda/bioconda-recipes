#!/bin/bash

mkdir -p bin

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CXXFLAGS} -I${PREFIX}/include -L${PREFIX}/lib -Wno-format -Wno-unused-result -Wno-unused-local-typedefs -O3 -fpermissive"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-O3|-O3 -fpermissive -I$(PREFIX)/include|' Makefile
rm -rf *.bak

sed -i.bak 's|$(EXTRA_CXXFLAGS)|$(EXTRA_CXXFLAGS) -fpermissive|' src/bowtie/Makefile
sed -i.bak 's|PTHREAD_LIB = -lpthread|PTHREAD_LIB = -pthread|' src/bowtie/Makefile
rm -rf src/bowtie/*.bak

sed -i.bak 's|gcc|$(CC)|' samtools-0.1.9/Makefile
rm -rf samtools-0.1.9/*.bak

make CXX="${CXX}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 755 mapsplice.py "${PREFIX}/bin"
install -v -m 755 bin/* "${PREFIX}/bin"
