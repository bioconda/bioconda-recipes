#!/bin/bash
set -euxo pipefail

mkdir -p "$PREFIX/bin"

echo "Setting environment variables"
# Fix zlib
export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export C_INCLUDE_PATH="${PREFIX}/include"

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak "s|-static||g" Makefile && rm -f *.bak
fi

echo "RUN MAKE"
make test CC="${CC}"

install -v -m 0755 rtk2 "$PREFIX/bin"
