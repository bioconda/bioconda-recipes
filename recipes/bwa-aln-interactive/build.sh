#!/bin/bash

make CC="$CC" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" -j "${CPU_COUNT}"
mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin/bwa-aln-interactive
