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

# ClustalW's ./configure may fail on macOS when the SDK is not accessible
# (xcrun --show-sdk-version returns NA).  Pre-create an empty config.h so
# that compilation can succeed even when configure does not produce one.
mkdir -p src/ClustalW/src
touch src/ClustalW/src/config.h

$R CMD INSTALL --build .