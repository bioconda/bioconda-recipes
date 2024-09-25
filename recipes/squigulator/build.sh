#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC=$CC CXX=$CXX 
mkdir -p $PREFIX/bin
cp squigulator $PREFIX/bin/squigulator
