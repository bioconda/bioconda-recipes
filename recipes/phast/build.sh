#!/bin/sh

mkdir -p $PREFIX/bin

cd src
make

cd ..
chmod +x bin/dless
chmod +x bin/exoniphy
chmod +x bin/phastCons
chmod +x bin/phastOdds
chmod +x bin/phastMotif
chmod +x bin/phyloFit
chmod +x bin/phyloBoot
chmod +x bin/phyloP
chmod +x bin/prequel
chmod +x bin/util

mv bin/dless $PREFIX/bin
mv bin/exoniphy $PREFIX/bin
mv bin/phastCons $PREFIX/bin
mv bin/phastOdds $PREFIX/bin
mv bin/phastMotif $PREFIX/bin
mv bin/phyloFit $PREFIX/bin
mv bin/phyloBoot $PREFIX/bin
mv bin/phyloP $PREFIX/bin
mv bin/prequel $PREFIX/bin
mv bin/util $PREFIX/bin


# Build lastz and lastz_D (lastz_D uses floating-point scores
# make
# # Build lastz_32, which uses 32-bit positions index and can handle genomes larger than 2Gb
# make lastz_32

# chmod +x src/lastz
# chmod +x src/lastz_D
# chmod +x src/lastz_32

# mv src/lastz $PREFIX/bin
# mv src/lastz_D $PREFIX/bin
# mv src/lastz_32 $PREFIX/bin
