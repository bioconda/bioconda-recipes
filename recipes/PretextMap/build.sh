#!/bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     file=PretextMap_Linux-x86-64.zip;;
    Darwin*)    file=PretextMap_MacOS.zip;;
esac

wget https://github.com/wtsi-hpag/PretextMap/releases/download/$PKG_VERSION/$file
mkdir -p $PREFIX/bin
unzip $file -d $PREFIX/bin
for f in $PREFIX/bin/PretextMap*; do
    chmod +x $f;
done
