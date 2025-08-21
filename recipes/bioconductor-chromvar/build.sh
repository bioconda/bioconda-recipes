#!/bin/bash

export DISABLE_AUTOBREW=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]]; then
  sed -i.bak 's|$(FLIBS)|-L$(PREFIX)/lib/gcc/arm64-apple-darwin20.0.0/13.3.0 -lgfortran -lquadmath -lm -L$(PREFIX)/lib/R/lib -lR -Wl,-framework -Wl,CoreFoundation|' src/Makevars
  rm -rf src/*.bak
fi

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
