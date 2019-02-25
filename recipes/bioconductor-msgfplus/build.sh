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
export PATH=$PREFIX/bin:$PATH
hash -r
which -a java
Rscript -e "print(Sys.which('java'))"
$R CMD INSTALL --build .
