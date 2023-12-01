#!/bin/bash

OS=$(uname)

if [ "$OS" = "Darwin" ]; then

    pkgutil --expand "$SRC_DIR"/mafft* "$SRC_DIR"/pkg

    tar xvf "$SRC_DIR"/pkg/mafft*/Payload --directory "$PREFIX"


elif [ "$OS" = "Linux" ]; then
    cd "$SRC_DIR"/core || exit 1

    make CC="$CC" CFLAGS="$CFLAGS" PREFIX="$PREFIX" DASH_CLIENT="dash_client"
    make install PREFIX="$PREFIX" DASH_CLIENT="dash_client"
fi
