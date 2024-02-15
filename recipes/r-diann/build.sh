#!/bin/bash

export CPATH="${PREFIX}/lib/R/library/RcppEigen/include:${CPATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

$R CMD INSTALL --build .
