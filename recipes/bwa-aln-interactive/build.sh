#!/bin/bash

make CC="$CC" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS"
mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin/bwa-aln-interactive
