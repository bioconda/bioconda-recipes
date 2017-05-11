#!/bin/sh
ls $PREFIX
ls
cd Misc/Applications/RNAshapes/
ls
ls $PREFIX
PREFIX=$PREFIX && make all 
ls $PREFIX/bin/
ls $PREFIX/lib/
cp x86_*/* $PREFIX/bin/
cp x86_* $PREFIX/bin/ -r
cp ../lib/* $PREFIX/lib/ -r
cp RNAshapes $PREFIX/bin/
chmod +x $PREFIX/bin/*
ls
ls $PREFIX
ls $PREFIX/bin/
ls $PREFIX/lib/


