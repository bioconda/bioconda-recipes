#!/bin/bash

export CPATH="${PREFIX}/lib/R/library/RcppEigen/include:${CPATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

echo "CPATH: $CPATH"
echo "LIBRARY_PATH: $LIBRARY_PATH"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "CXXFLAGS: $CXXFLAGS"
echo "LDFLAGS: $LDFLAGS"

$R CMD INSTALL --build .
