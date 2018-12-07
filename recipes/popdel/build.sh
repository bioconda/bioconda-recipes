#!/bin/sh
DATE=2018-12-06

make CXX=${CXX} VERSION=${PKG_VERSION} DATE=${DATE}
mkdir -p ${PREFIX}/bin
cp popdel ${PREFIX}/bin
