#!/usr/bin/env bash
set -e
set -x

platform="$(uname)"
unzip v2023.01.0.zip
make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -mcmodel=large -fpic -shared"
mkdir -p "$PREFIX"/bin
cp comet.exe ${PREFIX}/bin/comet
chmod a+x ${PREFIX}/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
