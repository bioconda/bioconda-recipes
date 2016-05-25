#!/bin/bash

export MACHTYPE=x86_64
export BINDIR=$(pwd)/bin
mkdir -p $BINDIR
(cd kent/src/lib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/utils/bedRestrictToPositions && make)
mkdir -p $PREFIX/bin
cp bin/bedRestrictToPositions $PREFIX/bin
chmod +x $PREFIX/bin/bedRestrictToPositions
