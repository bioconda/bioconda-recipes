#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    export LDFLAGS="-Wl,--allow-multiple-definition $LDFLAGS"
else
    export CFLAGS="$CFLAGS -fcommon"
fi

./configure --prefix=${PREFIX}
make
make install
