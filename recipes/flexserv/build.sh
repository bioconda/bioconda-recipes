#!/usr/bin/env bash

# Copy executables to environment bin dir included in the path
mkdir -p $PREFIX/bin

# Compile using make
make \
    F77="${FC}"

# BD
chmod u+x bd/bd
cp bd/bd $PREFIX/bin/

# DMD
chmod u+x dmd/dmdgoopt
cp dmd/dmdgoopt $PREFIX/bin/

# NMA
chmod u+x nma/lorellnma
cp nma/lorellnma $PREFIX/bin/
chmod u+x nma/diaghess/diaghess
cp nma/diaghess/diaghess $PREFIX/bin/
chmod u+x nma/nmanu.pl
cp nma/nmanu.pl $PREFIX/bin/
chmod u+x nma/mc-eigen.pl
cp nma/mc-eigen.pl $PREFIX/bin/
chmod u+x nma/mc-eigen-mdweb.pl
cp nma/mc-eigen-mdweb.pl $PREFIX/bin/
chmod u+x nma/pca_anim_mc.pl
cp nma/pca_anim_mc.pl $PREFIX/bin/
