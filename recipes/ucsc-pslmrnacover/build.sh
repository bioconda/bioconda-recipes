#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp pslMrnaCover "$PREFIX/bin"
else
    export MACHTYPE=x86_64
    export BINDIR=$(pwd)/bin
    mkdir -p "$BINDIR"
    (cd kent/src/lib && make)
    (cd kent/src/htslib && make)
    (cd kent/src/jkOwnLib && make)
    (cd kent/src/hg/lib && make)
    (cd kent/src/hg/mouseStuff/pslMrnaCover && make)
    cp bin/pslMrnaCover "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/pslMrnaCover"
