#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDE="-I$PREFIX/include" LIB_DIR="$PREFIX/lib"
cp bin/TideHunter $PREFIX/bin
