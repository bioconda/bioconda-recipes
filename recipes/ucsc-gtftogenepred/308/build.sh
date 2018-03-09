#!/bin/bash
mkdir -p "$PREFIX/bin"
export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin
mkdir -p "$BINDIR"
(cd src/lib && make)
(cd src/jkOwnLib && make)
(cd src/hg/lib && make)
(cd src/hg/utils/gtfToGenePred && make)
cp $BINDIR/gtfToGenePred "$PREFIX/bin"
chmod +x "$PREFIX/bin/gtfToGenePred"
