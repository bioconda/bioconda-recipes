#!/bin/sh

mkdir -p $PREFIX/bin

# Build lastz and lastz_D (lastz_D uses floating-point scores
make
# Build lastz_32, which uses 32-bit positions index and can handle genomes larger than 2Gb
make lastz_32

chmod +x src/lastz
chmod +x src/lastz_D
chmod +x src/lastz_32

mv src/lastz $PREFIX/bin
mv src/lastz_D $PREFIX/bin
mv src/lastz_32 $PREFIX/bin
