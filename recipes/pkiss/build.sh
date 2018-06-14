#!/bin/sh
cd Misc/Applications/pKiss/
PREFIX=$PREFIX && make all 
cp x86_*/* $PREFIX/bin/
cp ../lib/* $PREFIX/lib/ -r
cp pKiss* $PREFIX/bin/
chmod +x $PREFIX/bin/*
