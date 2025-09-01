#!/bin/bash

set -xe

mkdir build
cd build

cmake ..
make

mkdir -p "$PREFIX/bin/"
cp probe "$PREFIX/bin/"
