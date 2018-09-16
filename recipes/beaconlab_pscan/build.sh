#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
g++ pscan.cpp -o pscan -O3 -lgsl -lgslcblas

mv $SRC_DIR/pscan $PREFIX/bin/
chmod +x $PREFIX/bin/pscan