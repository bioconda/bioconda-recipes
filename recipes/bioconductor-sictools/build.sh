#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

# 1. Allow CC to be overridden by the environment (uses ?=)
sed -i 's/^CC=/CC?=/g' Makefile

# 2. Allow CFLAGS to be appended to (uses +=)
sed -i 's/^CFLAGS=/CFLAGS+=/g' Makefile

# 3. Ensure LDFLAGS are used and include the Conda library path
# We replace the commented LDFLAGS line with a functional one
sed -i 's|^#LDFLAGS=|LDFLAGS += -L$(PREFIX)/lib |g' Makefile

sed -i 's/-lcurses/-lncurses/g' src/Makefile



echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
