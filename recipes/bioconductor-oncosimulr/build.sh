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
if [[ $OSTYPE == "darwin"* ]]; then
  sed -i.bak "s/OncoSimulR.so/OncoSimulR.dylib/g" src/install.libs.R
fi
$R CMD INSTALL --build .
