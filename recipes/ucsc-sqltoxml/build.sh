#!/bin/bash

export MACHTYPE=x86_64
export BINDIR=$(pwd)/bin
mkdir -p $BINDIR
(cd kent/src/lib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/hg/sqlToXml && make)
mkdir -p $PREFIX/bin
cp bin/sqlToXml $PREFIX/bin
chmod +x $PREFIX/bin/sqlToXml
