#!/bin/bash

# fail on all errors
set -e

mkdir -p "$PREFIX/bin"

pushd src
make clean TARGET_DIR=$PREFIX CC=$CC CXX=$CXX
make TARGET_DIR=$PREFIX CC=$CC CXX=$CXX

# This installs all of the object files as well, remove that
rm -rf $PREFIX/*amd64
