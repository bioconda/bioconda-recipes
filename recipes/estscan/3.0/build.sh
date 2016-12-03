#!/bin/bash

mkdir -p $PREFIX/bin

export ESTSCANDIR=$PREFIX

sed -i -e 's/g77/gfortran/' Makefile

make

#cp build_model $PREFIX/bin
cp estscan $PREFIX/bin
