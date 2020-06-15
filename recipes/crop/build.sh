#!/bin/bash

#export INCLUDE_PATH=${PREFIX}/include
#export LIBRARY_PATH=${PREFIX}/lib

#export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include

# compile crop 
#echo $PREFIX
#echo $INCLUDE_PATH
#echo $LIBRARY_PATH
#echo $C_INCLUDE_PATH
#echo $CPLUS_INCLUDE_PATH
echo $CXX

make CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/gsl" LDFLAGS="$LDFLAGS" CXX=$CXX

# cp executables
mkdir -p $PREFIX/bin
cp -pf CROPLinux $PREFIX/bin
