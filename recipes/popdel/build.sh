#!/bin/sh
VERSION=1.0.5
DATE=2018-12-06

make CXX=${CXX} VERSION=${VERSION} DATE=${DATE}
mkdir -p ${PREFIX}/bin
cp popdel ${PREFIX}/bin
