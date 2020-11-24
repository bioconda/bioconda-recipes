#!/usr/bin/env bash

# Change to src directory
cd src

# Compile using make
make \
    F77="${FC}" \
    CPP="${CXX}"

# Copy executable to environment bin dir included in the path
mkdir -p $PREFIX/bin

chmod u+x cmip
cp cmip $PREFIX/bin/

cd ..
mkdir -p $PREFIX/share/cmip
cp -r dat tests wrappers scripts $PREFIX/share/cmip/
