#!/bin/bash

set -e

cd src

cmake .
make

mkdir -p $PREFIX/bin
cp FALCON2 $PREFIX/bin/falcon2