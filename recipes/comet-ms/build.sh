#!/usr/bin/env bash
set -e
set -x

platform="$(uname)"
unzip comet_source_"$PKG_VERSION".zip
if [ "$platform" = "Darwin" ]; then
    sed -i.bak -e 's/ -static//' -e 's/ -o / -headerpad_max_install_names&/' Makefile
    sed -i.bak -e "s/sha1Report='..'/sha1Report=NULL/" MSToolkit/include/MSReader.h
fi
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" CometSearch/CometSearch.cpp
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" Makefile
make CXX=${CXX}
mkdir -p "$PREFIX"/bin
cp comet.exe ${PREFIX}/bin/comet
chmod a+x ${PREFIX}/bin/comet
cd "$PREFIX"/bin/
ln -sr comet comet.exe
