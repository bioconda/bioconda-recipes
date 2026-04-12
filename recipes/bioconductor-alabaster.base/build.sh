#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

# TODO: this workaround can be dropped once R v4.4.3 build 4+ are used
if [ "$(uname)" == "Darwin" ]; then
  sed -i 's/-mmacosx-version-min=10.13/-mmacosx-version-min=10.15/g' ${PREFIX}/lib/R/etc/Makeconf
fi

mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

$R CMD INSTALL --build . "${R_ARGS}"
