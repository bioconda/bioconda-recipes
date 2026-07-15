#!/bin/bash

export DISABLE_AUTOBREW=1

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/graphviz/config/
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* ./

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

mkdir -p ~/.R

echo -e "CC=$CC
FC=$FC
CC17=$CC -std=gnu11
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

autoreconf -if

$R CMD INSTALL --build .
