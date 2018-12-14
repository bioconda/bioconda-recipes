#!/bin/bash

mkdir -p "$PREFIX/bin"

make -j
cp bin/filtlong $PREFIX/bin
