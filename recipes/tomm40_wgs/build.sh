#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/TOMM40_WGS

# Full path to the Snakefile
sed -i.bak "s|^SCRIPT_DIR=.*|SCRIPT_DIR=${PREFIX}/opt/TOMM40_WGS|" TOMM40_WGS 

cp -rf * $PREFIX/opt/TOMM40_WGS/
ln -sf $PREFIX/opt/TOMM40_WGS/TOMM40_WGS $PREFIX/bin/
