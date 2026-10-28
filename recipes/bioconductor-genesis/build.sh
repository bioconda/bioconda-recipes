#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH:-}"
if [[ -e "${PREFIX}/lib/libopenblas.so" && ! -e "${PREFIX}/lib/libopenblas.so.0" ]]; then
  ln -s "${PREFIX}/lib/libopenblas.so" "${PREFIX}/lib/libopenblas.so.0"
fi
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
