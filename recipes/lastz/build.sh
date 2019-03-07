#!/bin/sh

mkdir -p $PREFIX/bin

make
make lastz_32

chmod +x src/lastz
chmod +x src/lastz_D
chmod +x src/lastz_32

mv src/lastz $PREFIX/bin
mv src/lastz_D $PREFIX/bin
mv src/lastz_32 $PREFIX/bin
