#! /bin/bash
mkdir -p "${PREFIX}"/bin

make clean
make CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" prefix="${PREFIX}" CC="${CC}" CXX="${CXX} -L${PREFIX}/lib" LDFLAGS+="-lz -lpthread ${LDFLAGS} -L${PREFIX}/lib"
mv ./refFinder "${PREFIX}"/bin/
