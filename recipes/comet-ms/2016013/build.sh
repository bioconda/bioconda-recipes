#!/usr/bin/env bash
set -e
set -x

platform="$(uname)"
if [ "$platform" = "Darwin" ]; then
	unzip comet_source_"$PKG_VERSION".zip
	sed -i bak -e 's/ -static//' Makefile
	CXXFLAGS="${CXXFLAGS} -std=c++03" make
elif [ "$platform" = "Linux" ]; then
	mv comet."$PKG_VERSION".linux.exe comet.exe
fi
chmod 755 comet.exe
mkdir -p "$PREFIX"/bin
cp comet.exe "$PREFIX"/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
