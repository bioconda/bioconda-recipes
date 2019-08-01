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
$R CMD INSTALL --build .
if [[ $OSTYPE == darwin* ]]; then
  ln -s $PREFIX/lib/R/library/graph/libs/BioC_graph.dylib $PREFIX/lib/R/library/graph/libs/graph.dylib
fi
