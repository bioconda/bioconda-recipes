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
if [[ "$(uname)" == Darwin ]]; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION" $R CMD INSTALL --build .
else
    $R CMD INSTALL --build .
fi
