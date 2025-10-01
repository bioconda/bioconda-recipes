#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export DISABLE_AUTOBREW=1

sed -i.bak 's|CC = $(GCC_PREFIX)/gcc$(GCC_SUFFIX)|CC ?= $(CC)|' src/Makefile
sed -i.bak 's|CXX = $(CPP)|CXX ?= $(CXX)|' src/Makefile
sed -i.bak 's|ar rc|$(AR) rcs|' src/Makefile
sed -i.bak 's|g++|$(CXX)|' src/Makefile
sed -i.bak 's|-lpthread|-pthread|' src/Makefile
rm -f src/*.bak

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
