#!/bin/bash

export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

# Inject compilers and hack in the library path
sed -i.bak "s#g++#${CXX} -L${PREFIX}/lib#g" src/pirs/gccMakefile
sed -i.bak "s#g++#${CXX} -L${PREFIX}/lib#g" src/stator/gcContCvgBias/Makefile

make

# Link tools to PREFIX
find . -type l | while read a; do cp --copy-contents -LR  "$a" ${PREFIX}/bin; done

# Add required profiles in share/
mkdir -p ${PREFIX}/share/pirs
cp -R ./src/pirs/Profiles/* ${PREFIX}/share/pirs
