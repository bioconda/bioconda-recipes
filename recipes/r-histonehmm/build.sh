#!/bin/bash
#mkdir /Users/runner/.R
#FC=$FC
#CXX=$CXX -I$PREFIX/include -I$PREFIX/lib/R/library/Rcpp/include
#CXX98=$CXX -I$PREFIX/include -I$PREFIX/lib/R/library/Rcpp/include
#CXX11=$CXX -I$PREFIX/include -I$PREFIX/lib/R/library/Rcpp/include
#CXX14=$CXX -I$PREFIX/include -I$PREFIX/lib/R/library/Rcpp/include" > /Users/runner/.R/Makevars
$R CMD INSTALL --build .
