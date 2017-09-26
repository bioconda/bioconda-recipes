#!/bin/bash

sed -i 's/GATB_VER=1.0.6/GATB_VER=1.3.0/' Makefile
sed -i 's/GATB=gatb-core-$(GATB_VER)-Linux/GATB=$(PREFIX)/' Makefile

mkdir -p ${PREFIX}/bin

#mkdir -p build
#cd build

#cmake ..
make
cp tools/lordec-* ${PREFIX}/bin
