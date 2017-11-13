#!/bin/bash
target=$PREFIX/share/java/mintmap
mkdir -p $target
mkdir -p $PREFIX/bin
cp -r * $target
chmod +x $target/MINTmap.pl
ln -s $target/MINTmap.pl $PREFIX/bin/MINTmap.pl
