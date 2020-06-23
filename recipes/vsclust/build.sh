#!/bin/bash

# compile library
R CMD INSTALL e1071FuzzVec_Installation

# move all files to outdir and link into it by bin executor
mkdir -p $PREFIX/bin
cp -R * $PREFIX/bin
chmod a+x $PREFIX/bin/runVSClust.R




