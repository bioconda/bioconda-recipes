#!/bin/sh
ls $PREFIX
ls
cd Misc/Applications/RNAshapes/
ls
ls $PREFIX
PREFIX=$PREFIX && make all 
ls
cp x86_*/* $PREFIX/bin/
cp x86_* $PREFIX/bin/ -r 
cp RNAshapes $PREFIX/bin/
ls
ls $PREFIX

