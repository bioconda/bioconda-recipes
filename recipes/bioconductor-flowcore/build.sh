#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX -fcommon
CXX98=$CXX -fcommon
CXX11=$CXX -fcommon
CXX14=$CXX -fcommon" > ~/.R/Makevars
$R CMD INSTALL --build .
