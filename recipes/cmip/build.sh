#!/usr/bin/env bash

# Change to src directory
cd src

# Compile using make
make

# Copy executable to environment bin dir included in the path
mkdir -p $PREFIX/bin

chmod u+x cmip
cp cmip $PREFIX/bin/
