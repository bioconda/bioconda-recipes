#!/usr/bin/env bash
set -e
set -x

make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -mcmodel=large -fpic" CFLAGS="${CFLAGS} -mcmodel=large -fpic"
mkdir -p "$PREFIX"/bin
cp comet.exe ${PREFIX}/bin/comet
chmod a+x ${PREFIX}/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
