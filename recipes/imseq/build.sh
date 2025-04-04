#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/imseq

cmake ./seqan_minimal/
make
cp -f bin/imseq $PREFIX/bin/imseq

chmod +x $PREFIX/bin/imseq
cp -f Homo.Sapiens.*.fa $PREFIX/share/imseq/
