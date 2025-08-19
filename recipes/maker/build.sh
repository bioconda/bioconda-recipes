#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/perl/lib"

export LC_ALL="en_US.UTF-8"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# We will need this script to precompile inline C code for MPI support
cp -f maker_mpi_init $PREFIX/bin/
rm -f maker_mpi_init
chmod a+x $PREFIX/bin/maker_mpi_init

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/bin/*
rm -rf src/bin/*.bak

cd src/

# enable mpi
echo "yes" | perl Build.PL

perl ./Build install

cd ..

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/maker
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/*.pl
rm -rf bin/*.bak
install -v -m 755 bin/* "${PREFIX}/bin"
mv perl/lib/* "${PREFIX}/perl/lib/"
mv lib/* "${PREFIX}/lib"

# Run a first time MPI_Init() to pre compile inline C code
mpiexec -n 1 ${PREFIX}/bin/maker_mpi_init || true
# This is not needed anymore
rm -f ${PREFIX}/bin/maker_mpi_init
