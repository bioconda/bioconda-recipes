#!/bin/bash

pwd
echo "This should work"

mkdir -p $PREFIX/bin
cp rad_haplotyper.pl $PREFIX/bin
chmod +x $PREFIX/bin/rad_haplotyper.pl

