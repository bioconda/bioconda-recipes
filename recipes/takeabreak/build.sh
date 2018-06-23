#!/bin/bash

#strictly use anaconda build environment
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

# installation
sh INSTALL

# copy binary
cp build/bin/TakeABreak ${PREFIX}/bin
