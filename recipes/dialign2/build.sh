#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
#sed -i.bak -e 's/-march=i686/-march=native/' ./source/Makefile

mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/share
mkdir -p $PREFIX/share/dialign2

cd src
make

mv -t $PREFIX/bin/ dialign2-2
mv -t $PREFIX/share/dialign2 dialign2_dir/tp400_dna dialign2_dir/tp400_prot dialign2_dir/tp400_trans dialign2_dir/BLOSUM
export DIALIGN2_DIR="$PREFIX/share/dialign2"
