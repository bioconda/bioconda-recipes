#!/usr/bin/env bash

# Change folder, compiling BD
cd bd
sh compile.conda.sh
cd ..

# Change folder, compiling DMD
cd dmd
sh compile.conda.sh
cd ..

# Change folder, compiling NMA
cd nma
cd diaghess; make F77="${FC}"; cd ..;
sh compile.conda.sh
cd ..

# Copy executables to environment bin dir included in the path
mkdir -p $PREFIX/bin

# BD
chmod u+x bd/bd
cp bd/bd $PREFIX/bin/

# DMD
chmod u+x dmd/dmdgoopt
cp dmd/dmdgoopt $PREFIX/bin/

# NMA
chmod u+x nma/diaghess/diaghess
cp nma/diaghess/diaghess $PREFIX/bin/
chmod u+x nma/nmanu.pl
cp nma/nmanu.pl $PREFIX/bin/
chmod u+x nma/mc-eigen.pl
cp nma/mc-eigen.pl $PREFIX/bin/
chmod u+x nma/pca_anim_mc.pl
cp nma/pca_anim_mc.pl $PREFIX/bin/
