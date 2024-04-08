#!/bin/bash

mkdir -p $PREFIX/bin

meson setup build --prefix=$PREFIX
cd build
ninja install