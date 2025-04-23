#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/TOMM40_WGS/

# Full path to the Snakefile
sed -i 's|^SCRIPT_DIR=.*|SCRIPT_DIR="$PREFIX/opt/TOMM40_WGS"|' TOMM40_WGS 

cp -r * $PREFIX/opt/TOMM40_WGS/
ln -s $PREFIX/opt/TOMM40_WGS/TOMM40_WGS $PREFIX/bin/

