#!/bin/sh

autoconf
./configure --with-bam_tools_headers="${PREFIX}/include/bamtools" --with-bam_tools_library="${PREFIX}/lib"
make() { command make CXX="${CXX}" CFLAGS="${CFLAGS} ${LDFLAGS}" CXXFLAGS="${CXXFLAGS} ${LDFLAGS}" "${@}" ; }
make
make test
make install

mkdir -p "${PREFIX}/bin"
cp bin/* "${PREFIX}/bin/"
