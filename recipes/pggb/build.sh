#!/bin/bash

# Write version in the script
n=$(grep '"$show_version" == true' ./pggb -n | cut -f 1 -d :)
n=$((n-1))
sed -i ${n}'a\if [ "$show_version" == true ]; then echo "pggb '$PKG_VERSION'"; exit; fi' ./pggb

mkdir -p $PREFIX/bin

mv pggb $PREFIX/bin
mv partition-before-pggb $PREFIX/bin
cp scripts/*.py $PREFIX/bin
mv scripts $PREFIX/bin

#pggb -i data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 800,900,1100 -n 10 -Z -V 'gi|568815561:#,gi|29124352:#:10000' -M -m -o drib1_spoa
