#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    export CFLAGS="$CFLAGS -fcommon"
else
    export LDFLAGS="-Wl,--allow-multiple-definition $LDFLAGS"
fi

./configure --prefix=${PREFIX}
make
make install
