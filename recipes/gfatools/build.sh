#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|gcc|$(CC)|' paf2gfa/Makefile
sed -i.bak 's|-O2|-O3|' paf2gfa/Makefile
sed -i.bak 's|-std=c99|-std=c11|' paf2gfa/Makefile
sed -i.bak 's|-I..|-I.. -I$(PREFIX)/include|' paf2gfa/Makefile
rm -rf paf2gfa/*.bak

make CC="${CC}" LIBS="-L${PREFIX}/lib -lz" -j"${CPU_COUNT}"
make -C paf2gfa CC="${CC}" LIBS="-L${PREFIX}/lib -lz" -j"${CPU_COUNT}"

install -v -m 0755 gfatools "${PREFIX}/bin"
install -v -m 0755 paf2gfa/paf2gfa "${PREFIX}/bin"
