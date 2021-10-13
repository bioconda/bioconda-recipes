#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
echo -e "CC=$CC -I$PREFIX/include/fuse3
FC=$FC
CXX=$CXX -I$PREFIX/include/fuse3
CXX98=$CXX -I$PREFIX/include/fuse3
CXX11=$CXX -I$PREFIX/include/fuse3
CXX14=$CXX -I$PREFIX/include/fuse3" > ~/.R/Makevars
$R CMD INSTALL --build .
