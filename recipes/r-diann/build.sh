#!/bin/bash

export CPATH="${PREFIX}/lib/R/library/RcppEigen/include:${CPATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

echo "RcppEigen Path"
ls -l ${PREFIX}/lib/R/library/RcppEigen/

echo "R library Path"
ls -l ${PREFIX}/lib/R/library

echo "R Path"
ls -l ${PREFIX}/lib/R/

$R CMD INSTALL --build .
