#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

Rscript -e "Rcpp:::CxxFlags()"

$R CMD INSTALL --build . "${R_ARGS}"
