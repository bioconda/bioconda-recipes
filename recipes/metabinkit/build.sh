#!/usr/bin/env bash

# Remove incorrect test for R version which fails with R 4.0 when it should pass
# The version of R will always be 4.0 until 2021 (when it will be 4.1)
sed -i.bak "27,31d" R/metabinkit.R

# run the install script with -C (conda mode)
./install.sh -i $PREFIX -C
cp exe/* $PREFIX/bin/
