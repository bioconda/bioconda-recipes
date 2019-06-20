#!/bin/bash
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
make
mkdir -p "$PREFIX/bin"
cp netcdf-metadata-info "$PREFIX/bin"
