#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
#sed -i.bak -e 's/-march=i686/-march=native/' ./source/Makefile
cd ./src

mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/share
mkdir -p $PREFIX/share/dialign2
make
mv -t $PREFIX/bin/ dialign2-2
mv -t $PREFIX/share/dialign2 tp400_dna tp400_prot tp400_trans BLOSUM
export DIALIGN2_DIR="$PREFIX/share/dialign2"
