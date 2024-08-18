#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin 
cp -rf STITCH.R $PREFIX/bin

${R} CMD INSTALL --build . ${R_ARGS}

