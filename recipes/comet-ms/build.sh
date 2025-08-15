#!/usr/bin/env bash
set -e
set -x

export INCLUDE_PATH="${PREFIX}/MSToolkit/include"
export CPPFLAGS="-I${PREFIX}/MSToolkit/include"

# To switch from static to dynamic linking on linux. The Makefile does not have this flag for macOS
# Dynamic linking does not work with mulled container tests
#sed -i.bak 's#-static##' Makefile
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" MSToolkit/Makefile
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" CometSearch/Makefile

make CXX=${CXX} -j ${CPU_COUNT}

mkdir -p "$PREFIX"/bin
cp comet.exe ${PREFIX}/bin/comet
chmod a+x ${PREFIX}/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
