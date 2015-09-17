#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib/STAR-Fusion

make

cp -r * $PREFIX/lib/STAR-Fusion

echo "cd $PREFIX/lib/STAR-Fusion" > $PREFIX/bin/STAR-Fusion
echo "./STAR-Fusion \$@" >> $PREFIX/bin/STAR-Fusion
chmod +x $PREFIX/bin/STAR-Fusion
