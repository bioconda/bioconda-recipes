#!/bin/bash

cd src/

# enable mpi
echo "yes" | perl Build.PL

perl ./Build install

cd ..

mv bin/* $PREFIX/bin
mkdir -p $PREFIX/perl/lib/
mv perl/lib/* $PREFIX/perl/lib/
mv lib/* $PREFIX/lib/
