#!/bin/sh
git clone https://github.com/SurajGupta/r-source
cd r-source
./configure
cd src/nmath/standalone/
make
cp rmathlib/* $HOME/.nimble/lib/

cd ../../../../
rm r-source

nimble --localdeps build -y --verbose -d:release
mkdir -p "${PREFIX}/bin"
cp sscocaller "${PREFIX}/bin/"
