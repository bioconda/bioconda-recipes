#!/bin/bash

# compile crop 
make LDFLAGS="$LDFLAGS" CXX=$CXX

# cp executables
mkdir -p "$PREFIX/bin"
cp -pf CROPLinux "$PREFIX/bin/"
