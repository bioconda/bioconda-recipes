#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
make

cp nseg nmerge ${PREFIX}/bin
