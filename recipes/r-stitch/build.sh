#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin 
cp STITCH.R $PREFIX/bin

$R CMD INSTALL --build --install-tests .
