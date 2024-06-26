#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
cp -r * ${PREFIX}/bin
cd ${PREFIX}/bin/tetrimmer
