#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
sed -i.bak -e 's/-march=i686/-march=native/' ./source/Makefile
cd ./source

mkdir -p $PREFIX/bin
make
mv dialign-tx $PREFIX/bin/
