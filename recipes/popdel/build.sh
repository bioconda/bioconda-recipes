#!/bin/sh
make CXX=${CXX}
mkdir -p ${PREFIX}/bin
cp popdel ${PREFIX}/bin
