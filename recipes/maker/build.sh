#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/perl/lib"

# We will need this script to precompile inline C code for MPI support
cp -f maker_mpi_init $PREFIX/bin/
rm -f maker_mpi_init
chmod a+x $PREFIX/bin/maker_mpi_init

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/bin/*
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/inc/bundle/bin/config_data
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' MWAS/bin/*
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/Build.PL
rm -rf src/*.bak
rm -rf MWAS/bin/*.bak
rm -rf src/bin/*.bak
rm -rf src/inc/bundle/bin/*.bak

cd src/

# enable mpi
echo "yes" | perl Build.PL

perl ./Build install

cd ..

install -v -m 755 bin/* "${PREFIX}/bin"
mv perl/lib/* "${PREFIX}/perl/lib/"
mv lib/* "${PREFIX}/lib"

# Run a first time MPI_Init() to pre compile inline C code
mpiexec -n 1 ${PREFIX}/bin/maker_mpi_init || true
# This is not needed anymore
rm -f ${PREFIX}/bin/maker_mpi_init
