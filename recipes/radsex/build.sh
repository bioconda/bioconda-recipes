#!/bin/bash

# Create bin directory
mkdir -p $PREFIX/bin/

# Build radsex specifying CPP compiler and C compiler
make CXX=$CXX CC=$CC

# Copy all generated binaries to bin
cp bin/radsex $PREFIX/bin/radsex
