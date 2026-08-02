#!/bin/bash
if [[ "$(uname)" == "Darwin" ]]; then
  ln -sf "${BUILD_PREFIX}/bin/${HOST}-otool" "${BUILD_PREFIX}/bin/llvm-otool"
fi
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
