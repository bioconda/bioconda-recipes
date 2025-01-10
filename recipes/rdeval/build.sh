#!/usr/bin/bash

set -o errexit
set -o nounset

if [ -e "$PREFIX/include" ]; then
    export CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }-I${PREFIX}/include"
fi

if [ -e "$PREFIX/lib" ]; then
    export LDFLAGS="${LDFLAGS:+$LDFLAGS }-L${PREFIX}/lib"
fi

echo "CPPFLAGS=\"$CPPFLAGS\""
echo "LDFLAGS=\"$LDFLAGS\""

cd "$SRC_DIR"

make CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" -j"${CPU_COUNT}"

install -d "$PREFIX/bin"
install -v -m 0755 build/bin/rdeval "$PREFIX/bin"
