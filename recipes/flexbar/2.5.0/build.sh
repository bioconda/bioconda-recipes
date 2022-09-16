#!/bin/bash
export CPP_INCLUDE_PATH=${PREFIX}/include

cmake .
make

mkdir -p ${PREFIX}/bin
cp flexbar ${PREFIX}/bin
mkdir -p ${PREFIX}/share/doc/flexbar
cp *.md ${PREFIX}/share/doc/flexbar
