#!/bin/bash

mkdir -p $PREFIX/bin

meson setup build --prefix=$PREFIX/bin
cd build
ninja install