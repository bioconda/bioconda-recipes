#!/bin/bash

export DISABLE_AUTOBREW=1

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/graphviz/config/
cp -f ${RECIPE_DIR}/configure.ac ./

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

mkdir -p ~/.R

echo -e "CC=$CC
FC=$FC
CC17=$CC -std=gnu17
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

$R CMD INSTALL --build . --configure-args="--with-graphviz=${PREFIX}"
