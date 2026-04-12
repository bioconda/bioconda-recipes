#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -pv ${PREFIX}/bin ${PREFIX}/share/man/man1

sed -i.bak "s/-a //g" src/Makefile
rm -rf src/*.bak

make -C src -j"${CPU_COUNT}" CXX="${CXX}"

cp -f man/swarm.1 ${PREFIX}/share/man/man1
cp -f man/swarm_manual.pdf ${PREFIX}/share

install -v -m 0755 bin/swarm scripts/* "${PREFIX}/bin"
