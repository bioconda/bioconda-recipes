#!/bin/bash

# install gffcompare using the prep script of the 
# distribution. note that this works for linux and mac
# since the prep_mac script just uses different names
# for the directories (all the magic happens in the 
# Makefile)

export CXX="$CXX"
export LINKER="$CXX"

cd gffcompare
./prep_linux.sh

# in order to find the directory where the binaries 
# are installed the version is extracted as in the 
# prep script
ver=$(fgrep '#define VERSION ' gffcompare.cpp)
ver=${ver#*\"}
ver=${ver%%\"*}
cd gffcompare-"$ver"

# copy binaries
mkdir -p "$PREFIX"/bin/
cp gffcompare "$PREFIX"/bin/
cp trmap "$PREFIX"/bin/
