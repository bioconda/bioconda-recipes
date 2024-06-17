#!/bin/bash

if [ $(arch) = "aarch64" ]
then
    export CFLAGS+=" -O3 "
    export CPPFLAGS+=" -O3 "
else
    export MACHTYPE=x86_64
fi

export BINDIR=$(pwd)/bin
export L="${LDFLAGS}"

mkdir -p "$PREFIX/bin"
mkdir -p "$BINDIR"
(cd kent/src/lib && make)
(cd kent/src/htslib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/utils/bedClip && make)
cp bin/bedClip "$PREFIX/bin"
chmod +x "$PREFIX/bin/bedClip"
