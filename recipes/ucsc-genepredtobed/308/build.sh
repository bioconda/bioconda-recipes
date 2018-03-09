#!/bin/bash
export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin
mkdir -p "$BINDIR"
(cd src/lib && make)
(cd src/jkOwnLib && make)
(cd src/hg/lib && make)
(cd src/hg/genePredToBed && make)
cp $BINDIR/genePredToBed "$PREFIX/bin"

chmod +x "$PREFIX/bin/genePredToBed"
