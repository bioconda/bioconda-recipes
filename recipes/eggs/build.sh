#!/bin/bash
set -euxo pipefail
export SOURCE_DATE_EPOCH=0
export CFLAGS="${CFLAGS} -fdebug-prefix-map=$PWD=. -I lib"
export LDFLAGS="${LDFALGS} -W1 --build-id=none -I ${PREFIX}/include -g -o"
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/error.c -o lib/gsl/error.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/message.c -o lib/gsl/message.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/stream.c -o lib/gsl/stream.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/default.c -o lib/gsl/default.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/rng.c -o lib/gsl/rng.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/mt.c -o lib/gsl/mt.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/types.c -o lib/gsl/types.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/gauss.c -o lib/gsl/gauss.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/beta.c -o lib/gsl/beta.o
$CC $CFLAGS -DHAVE_INLINE -c lib/gsl/gamma.c -o lib/gsl/gamma.o
$CC $CFLAGS -c lib/kstring.c -o lib/kstring.o
$CC $CFLAGS -DHAVE_INLINE -c src/Missingness.c -o src/Missingness.o
$CC $CFLAGS -c src/GenotypeParser.c -o src/GenotypeParser.o
$CC $CFLAGS -c src/Interface.c -o src/Interface.o
$CC $CFLAGS -DHAVE_INLINE -c src/Main.c -o src/Main.o
mkdir -p bin
$CC $LDFLAGS bin/eggs src/*.o lib/*.o lib/gsl/*.o -lz -lm
mkdir -p "$PREFIX/bin"
cp bin/eggs "$PREFIX/bin"
chmod +x "$PREFIX/bin/eggs"
