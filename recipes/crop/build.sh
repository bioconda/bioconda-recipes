#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include

# compile crop 
make CXX=$CXX

# cp executables
mkdir -p "$PREFIX/bin"
cp -pf CROPLinux "$PREFIX/bin/"
