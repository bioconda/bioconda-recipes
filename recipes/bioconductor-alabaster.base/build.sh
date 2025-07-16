#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R

if [ "$(uname)" == "Darwin" ]; then
  # Let conda set the version
  sed -i.bak 's/-mmacosx-version-min=10.13//g' "${PREFIX}/lib/R/etc/Makeconf"
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=10.15"
fi

echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
