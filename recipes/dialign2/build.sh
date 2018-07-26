#!/bin/bash
set -euo pipefail
#export CPPFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/share
mkdir -p $PREFIX/share/dialign2

cd src
make
mv dialign2-2 $PREFIX/bin/dialign2-2-bin
echo "export DIALIGN2_DIR=${PREFIX}/share/dialign2 && dialign2-2-bin" > $PREFIX/bin/dialign2-2

cd ../dialign2_dir
mv -t $PREFIX/share/dialign2 tp400_dna tp400_prot tp400_trans BLOSUM
