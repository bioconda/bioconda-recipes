#!/bin/bash
mkdir -p "$PREFIX/bin"
export MACHTYPE=x86_64
export BINDIR=$(pwd)/bin
(cd kent/src/lib && make)
(cd kent/src/htslib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/hg/bedToGenePred && make)
cp bin/bedToGenePred "$PREFIX/bin"
chmod +x "$PREFIX/bin/bedToGenePred"
