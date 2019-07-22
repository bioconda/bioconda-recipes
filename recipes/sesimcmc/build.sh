#!/bin/bash
set -x

cd src/

ls
echo $CXX

source activate root
which gcc
$BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++ -v 

make
