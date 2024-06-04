#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./install_muse.sh

# make CPP="${CXX} ${LDFLAGS}" CPPFLAGS="${CXXFLAGS} -I${PREFIX}/include"

chmod 755 MuSE
cp -f MuSE "${PREFIX}/bin"
