#!/bin/bash

export DISABLE_AUTOBREW=1
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
#export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"

mkdir -p config
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* config/

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R

echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

${R} CMD INSTALL --build . "${R_ARGS}"
