#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin
cd hs-blastn-src
make
cp hs-blastn $PREFIX/bin
