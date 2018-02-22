#!/bin/bash
mkdir -p "$PREFIX/bin"
export MACHTYPE=$( uname -m )
export BINDIR=$(pwd)/bin
mkdir -p "$BINDIR"
(cd kent/src/lib && make)
(cd kent/src/htslib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/hg/ratStuff/mafSpeciesSubset && make)
cp $BINDIR/mafSpeciesSubset "$PREFIX/bin"
chmod +x "$PREFIX/bin/mafSpeciesSubset"
