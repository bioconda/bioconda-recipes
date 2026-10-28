#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
  git clone https://github.com/DLTcollab/sse2neon.git
  cp -f sse2neon/sse2neon.h $PREFIX/include
fi

cd src

make CC="$CC" CFLAGS="$CFLAGS $LDFLAGS"

install -v -m 0755 jgi_gc "$PREFIX/bin"
