#!/bin/bash

mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp nibFrag "$PREFIX/bin"
else
    sed -i.bak "s|^CC=gcc$|CC='${CC}'|g" kent/src/inc/common.mk
    export MACHTYPE=x86_64
    export BINDIR=$(pwd)/bin
    export L="${LDFLAGS}"
    mkdir -p "$BINDIR"
    (cd kent/src/lib && make)
    (cd kent/src/htslib && make)
    (cd kent/src/jkOwnLib && make)
    (cd kent/src/hg/lib && make)
    (cd kent/src/utils/nibFrag && make)
    cp bin/nibFrag "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/nibFrag"
