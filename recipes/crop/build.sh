#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

# compile crop 
make CXX=$CXX

# cp executables
mkdir -p $PREFIX/bin
cp -pf CROPLinux $PREFIX/bin
