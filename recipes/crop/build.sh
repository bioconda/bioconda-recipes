#!/bin/bash

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

#export CPLUS_INCLUDE_PATH=${PREFIX}/include

# compile crop 
# CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/gsl" LDFLAGS="$LDFLAGS"
make CXX=$CXX

# cp executables
mkdir -p $PREFIX/bin
cp -pf CROPLinux $PREFIX/bin
