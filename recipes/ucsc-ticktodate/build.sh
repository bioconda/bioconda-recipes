#!/bin/bash

export MACHTYPE=x86_64
export BINDIR=$(pwd)/bin
mkdir -p $BINDIR
(cd kent/src/lib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/utils/tickToDate && make)
mkdir -p $PREFIX/bin
cp bin/tickToDate $PREFIX/bin
chmod +x $PREFIX/bin/tickToDate
