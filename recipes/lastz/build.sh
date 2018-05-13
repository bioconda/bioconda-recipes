#!/bin/sh

mkdir -p $PREFIX/bin

make 

chmod +x  src/lastz
chmod +x  src/lastz_D

mv src/lastz $PREFIX/bin
mv src/lastz_D $PREFIX/bin
