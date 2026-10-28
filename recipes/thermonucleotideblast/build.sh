#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i.bak 's/#OPENMP/OPENMP/g' Makefile

make
cp tntblast ${PREFIX}/bin
