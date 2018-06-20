#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp hgLoadSqlTab "$PREFIX/bin"
else
    export MACHTYPE=x86_64
    export BINDIR=$(pwd)/bin
    mkdir -p "$BINDIR"
    (cd kent/src/lib && make)
    (cd kent/src/htslib && make)
    (cd kent/src/jkOwnLib && make)
    (cd kent/src/hg/lib && make)
    (cd kent/src/hg/makeDb/hgLoadSqlTab && make)
    cp bin/hgLoadSqlTab "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/hgLoadSqlTab"
