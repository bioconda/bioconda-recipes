#!/bin/bash

# Keep track of the process
set -uex

mkdir -p $PREFIX/bin
mv * $PREFIX/bin
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"

# Needs to run in the install folder
cd ${PREFIX}/bin

sh install.sh

