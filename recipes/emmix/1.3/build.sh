#!/bin/sh

mkdir -p $PREFIX/bin
# The EMMIX download page has a separate link for this required file.
wget --no-check-certificate https://people.smp.uq.edu.au/GeoffMcLachlan/emmix/EMMIX.max

gfortran -o EMMIX EMMIX.f
mv EMMIX $PREFIX/bin


