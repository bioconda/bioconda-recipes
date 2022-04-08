#!/bin/bash
# Set default for RNASNPPATH env var so we don't have to rely on activate scripts.
sed -Ei.bak "s|^(\s*if\(rnasnppath==NULL\)).*|\1 rnasnppath = \"${PREFIX}\";|" Progs/RNAsnp.c
./configure --prefix=$PREFIX
make
make install
cp -R lib/distParam $PREFIX/lib
