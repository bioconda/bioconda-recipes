#!/bin/bash

# Install methylpy
python -m pip install . --no-deps --ignore-installed -vv

# Install RMS
export CPATH=${PREFIX}/include
cd methylpy
$CXX -O3 -L${PREFIX}/lib -lgsl -lgslcblas -o run_rms_tests.out rms.cpp
# run_rms_tests.out needs to be copied to the directory where methylpy is installed
cp run_rms_tests.out ${PREFIX}/lib/python*/site-packages/methylpy/
cd ..
