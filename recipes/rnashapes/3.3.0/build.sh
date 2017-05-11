#!/bin/sh
ls $PREFIX
ls
cd Misc/Applications/RNAshapes/
ls
ls $PREFIX
PREFIX=$PREFIX && make all 
ls
cp x86_*/* $PREFIX
ls
ls $PREFIX

