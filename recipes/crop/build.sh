#!/bin/bash

# compile crop 
make LDFLAGS="$LDFLAGS" CPP=$CXX

# cp executables
mkdir -p "$PREFIX/bin"
cp -pf CROPLinux "$PREFIX/bin/"
