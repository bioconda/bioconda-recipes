#!/bin/bash

cd src/

source activate root
which gcc
$BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++ -v 
echo $CXX
make
