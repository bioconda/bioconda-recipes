#!/bin/bash

set -ex

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/src

# Will need to install databases, etc. later
mkdir -pv $PREFIX/share/${PKG_NAME}-${PKG_VERSION}

cp -rvf analysis_scripts/* $PREFIX/bin/
# scripts in bmgap2 look for scripts in analysis_scripts and so make a simple symlink
ln -sv $PREFIX/bin $PREFIX/analysis_scripts
cp -vf BMGAP-RUNNER.sh $PREFIX/bin/
