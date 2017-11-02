#!/bin/sh
cd Misc/Applications/RNAshapes/
PREFIX=$PREFIX && make all 
cp x86_*/* $PREFIX/bin/
cp ../lib/* $PREFIX/lib/ -r
cp RNAshapes $PREFIX/bin/
chmod +x $PREFIX/bin/*
