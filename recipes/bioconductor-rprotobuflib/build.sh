#!/bin/bash

export DISABLE_AUTOBREW=1

mv DESCRIPTION DESCRIPTION.old

grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R

echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

# Refresh stale autotools config so arm64-apple-darwin is recognized
for f in $(find . -name config.sub); do cp "$BUILD_PREFIX/share/gnuconfig/config.sub"   "$f"; done
for f in $(find . -name config.guess); do cp "$BUILD_PREFIX/share/gnuconfig/config.guess" "$f"; done

autoreconf -if

$R CMD INSTALL --build . "${R_ARGS}"
