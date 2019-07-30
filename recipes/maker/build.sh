#!/bin/bash
# We will need this script to precompile inline C code for MPI support
cp maker_mpi_init $PREFIX/bin/
rm maker_mpi_init
chmod a+x $PREFIX/bin/maker_mpi_init

cd src/

# enable mpi
echo "yes" | perl Build.PL

perl ./Build install

cd ..

# Maker needs to check RepeatMasker's libraries content which are not in the expected location
sed -i.bak 's|Libraries/RepeatMaskerLib.embl|../share/RepeatMasker/Libraries/RepeatMaskerLib.embl|g' lib/GI.pm

chmod 755 bin/*
mv bin/* $PREFIX/bin
mkdir -p $PREFIX/perl/lib/
mv perl/lib/* $PREFIX/perl/lib/
mv lib/* $PREFIX/lib/

# Run a first time MPI_Init() to pre compile inline C code
mpiexec -n 1 $PREFIX/bin/maker_mpi_init || true
# This is not needed anymore
rm $PREFIX/bin/maker_mpi_init
