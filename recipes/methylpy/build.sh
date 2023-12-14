#!/bin/bash

# Install methylpy
${PYTHON} -m pip install . --no-deps --no-build-isolation -vvv

# Install RMS
export CPLUS_INCLUDE_PATH=${PREFIX}/include
cd methylpy
${CXX} -O3 -L${PREFIX}/lib -lgsl -lgslcblas -o run_rms_tests.out rms.cpp
# run_rms_tests.out needs to be copied to the directory where methylpy is installed
cp run_rms_tests.out ${SP_DIR}/methylpy/
cd ..
