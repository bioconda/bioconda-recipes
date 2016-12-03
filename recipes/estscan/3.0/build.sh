#!/bin/bash

mkdir -p $PREFIX/bin

export ESTSCANDIR=$PREFIX

sed -i -e 's/F77/#F77/' Makefile
sed -i -e 's/winsegshuffle/#winsegshuffle/' Makefile

make

#cp build_model $PREFIX/bin
cp estscan $PREFIX/bin
