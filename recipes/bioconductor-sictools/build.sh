#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC -I$PREFIX/include -L$PREFIX/lib
FC=$FC
CXX=$CXX -I$PREFIX/include -L$PREFIX/lib
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
MAKE="make LIBCURSES=-lncurses" $R CMD INSTALL --build .
