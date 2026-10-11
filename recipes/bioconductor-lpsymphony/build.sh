#!/bin/bash

export DISABLE_AUTOBREW=1

mv DESCRIPTION DESCRIPTION.old

grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

mkdir -p ~/.R

echo -e "CC=$CC
FC=$FC
CXX=$CXX -Wno-register
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

sed -i.bak 's/CXXFLAGS="-w -g -O2"/CXXFLAGS="-w -g -O3 -std=gnu++14"/g' configure && rm -f configure.bak

$R CMD INSTALL --build . "${R_ARGS}"
