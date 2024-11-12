#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

cd "$SRC_DIR"

export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make
install -v -m 0755 build/bin/rdeval "$PREFIX/bin/rdeval"
