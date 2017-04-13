#!/bin/bash -u -f -e -o pipefail

mkdir -p $PREFIX/bin

cp CuReSim1.3/CuReSim.jar $PREFIX/bin
cp curesim $PREFIX/bin

