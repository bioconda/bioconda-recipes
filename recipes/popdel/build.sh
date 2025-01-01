#!/bin/sh
make CXX=${CXX} -j ${CPU_COUNT}
mkdir -p ${PREFIX}/bin
cp popdel ${PREFIX}/bin
