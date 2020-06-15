#!/bin/bash

# compile crop 
$HACK=$CXX" -I${PREFIX}/include"
make CXX=$HACK

# cp executables
mkdir -p "$PREFIX/bin"
cp -pf CROPLinux "$PREFIX/bin/"
