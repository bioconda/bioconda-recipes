#!/usr/bin/env bash
set -e
set -x

unzip comet_source_"$PKG_VERSION".zip
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" CometSearch/Makefile
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" MSToolkit/Makefile
make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -mcmodel=large"
mkdir -p "$PREFIX"/bin
cp comet.exe ${PREFIX}/bin/comet
chmod a+x ${PREFIX}/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
