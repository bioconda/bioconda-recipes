#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/gmap/config/
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/gstruct/config/

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
