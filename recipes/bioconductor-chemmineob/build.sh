#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include/eigen3"

# Prefer OpenBabel flags from the active conda environment.
if pkg-config --exists openbabel-3; then
  export OPENBABEL_CFLAGS="$(pkg-config --cflags openbabel-3)"
  export OPENBABEL_LIBS="$(pkg-config --libs openbabel-3)"
fi

echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
