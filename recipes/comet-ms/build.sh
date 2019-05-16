#!/usr/bin/env bash
set -e
set -x

platform="$(uname)"
if [ "$platform" = "Darwin" ]; then
	unzip comet_source_"$PKG_VERSION".zip
	sed -i '' -e 's/ -static//' -e 's/ -o / -headerpad_max_install_names&/' Makefile
	sed -i '' -e "s/sha1Report='..'/sha1Report=NULL/" MSToolkit/include/MSReader.h
	make
elif [ "$platform" = "Linux" ]; then
	mv comet."$PKG_VERSION".linux.exe comet.exe
fi
chmod 755 comet.exe
mkdir -p "$PREFIX"/bin
cp comet.exe "$PREFIX"/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
