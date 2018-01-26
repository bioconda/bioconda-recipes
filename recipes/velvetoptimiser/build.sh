#!/bin/bash
cp -r ./* $PREFIX/
mkdir -p $PREFIX/bin
ln -s $PREFIX/VelvetOptimiser.pl $PREFIX/bin/VelvetOptimiser.pl
sed -i -e "s/FindBin::Bin/FindBin::RealBin/" $PREFIX/VelvetOptimiser.pl
