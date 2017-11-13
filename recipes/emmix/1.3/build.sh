#!/bin/sh

mkdir -p $PREFIX/bin
# The EMMIX download page has a separate link for this required file.
wget --no-check-certificate https://people.smp.uq.edu.au/GeoffMcLachlan/emmix/EMMIX.max

# Adjust the max data points parameter that defines array sizes at
# compilation time, allowing for analyses that produce ks data points
# up to 100000 instead of the default value of 1000.
sed -i'' -e 's/MNIND=1000/MNIND=100000/g' EMMIX.max

gfortran -o EMMIX EMMIX.f
mv EMMIX $PREFIX/bin


