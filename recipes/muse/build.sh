#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3"

CC="${CC} -O3 ${LDFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS} -O3" \
	CPP="${CPP}" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	INCLUDES="${INCLUDES}" COMMONLIBS="${COMMONLIBS} -L${PREFIX}/lib" ./install_muse.sh

chmod 755 MuSE
cp -f MuSE "${PREFIX}/bin"
