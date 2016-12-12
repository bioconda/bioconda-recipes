#!/bin/bash

export MACHTYPE=x86_64
export BINDIR=$(pwd)/bin
mkdir -p $BINDIR
(cd kent/src/lib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/hg/dbTrash && make)
mkdir -p $PREFIX/bin
cp bin/dbTrash $PREFIX/bin
chmod +x $PREFIX/bin/dbTrash
