#!/bin/bash

# Create necessary directories
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/${PKG_NAME}/test

# Move executable scripts to bin directory
mv bin/*.py $PREFIX/bin

# Move test files to the standardized location
mv test/* $PREFIX/share/${PKG_NAME}/test