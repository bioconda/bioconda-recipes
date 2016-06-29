#!/bin/bash
cp -r ./* $PREFIX/
mkdir -p $PREFIX/bin
ln -s $PREFIX/VelvetOptimiser.pl $PREFIX/bin/VelvetOptimiser.pl
