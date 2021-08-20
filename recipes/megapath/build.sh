#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/MegaPath
rsync -av * $PREFIX/MegaPath
ln -s $PREFIX/MegaPath/runMegaPath.sh $PREFIX/bin

make -C $PREFIX/MegaPath/megahit/
make -C $PREFIX/MegaPath/soap4/2bwt-lib/ 
make -C $PREFIX/MegaPath/soap4/
