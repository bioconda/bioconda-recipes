#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i.bak 's/gmapR.so/gmapR.dylib/' src/Makefile
fi
$R CMD INSTALL --build .
