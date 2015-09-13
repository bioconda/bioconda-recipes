#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib/STAR-Fusion

cp bin/Linux_x86_64_static/* $PREFIX/bin

cp -r STAR-Fusion-0.1.1/* $PREFIX/lib/STAR-Fusion

echo "cd $PREFIX/lib/STAR-Fusion" > $PREFIX/bin/STAR-Fusion
echo "./STAR-Fusion \$@" >> $PREFIX/bin/STAR-Fusion
chmod +x $PREFIX/bin/STAR-Fusion
