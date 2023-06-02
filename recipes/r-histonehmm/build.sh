#!/bin/bash
Rscript -e "Rcpp:::CxxFlags()"
$R CMD INSTALL --build .
