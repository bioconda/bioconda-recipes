#!/bin/bash
mkdir -p "$PREFIX/bin"
export MACHTYPE=$( uname -m )
export BINDIR=$(pwd)/bin
mkdir -p "$BINDIR"
(cd kent/src/lib && make)
(cd kent/src/htslib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/hg/makeDb/hgFakeAgp && make)
cp $BINDIR/hgFakeAgp "$PREFIX/bin"
chmod +x "$PREFIX/bin/hgFakeAgp"
