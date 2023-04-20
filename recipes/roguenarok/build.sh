#!/bin/bash

mkdir -p $PREFIX/bin
#mkdir -p $PREFIX/share/RogueNaRok
make CC=$CC mode=parallel RogueNaRok
mv RogueNaRok-parallel $PREFIX/bin
make clean
make CC=$CC
mv RogueNaRok rnr-lsi rnr-mast rnr-prune rnr-tii $PREFIX/bin
make clean
#cp -r example $PREFIX/share/RogueNaRok
