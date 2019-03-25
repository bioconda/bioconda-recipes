#!/bin/sh

mkdir -p $PREFIX/bin

cd src
make CLAPACKPATH=$ORIGIN  # PHAST needs a path to Clapack libraries to compile

# PHAST builds multiple binaries
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

mv bin/dless $PREFIX/bin
mv bin/exoniphy $PREFIX/bin
mv bin/phastCons $PREFIX/bin
mv bin/phastOdds $PREFIX/bin
mv bin/phastMotif $PREFIX/bin
mv bin/phyloFit $PREFIX/bin
mv bin/phyloBoot $PREFIX/bin
mv bin/phyloP $PREFIX/bin
mv bin/prequel $PREFIX/bin
