#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/perl/lib"

cd src/

# enable mpi
echo "yes" | perl Build.PL

./Build install

cd ..

install -v -m 755 bin/* "${PREFIX}/bin"
mv src/lib/* "${PREFIX}/perl/lib/"
mv lib/* "${PREFIX}/lib/"
