#!/bin/bash
mkdir bin
pushd src
make CC=$CC CFLAGS="$CFLAGS -O2 -Wall -D VERBOSE -D PRINT_COVERAGE" LDFLAGS="$LDFLAGS -lz -lm"
popd
pushd util
make CC=$CC CFLAGS="$CFLAGS -O2 -Wall -D VERBOSE -D PRINT_COVERAGE" LDFLAGS="$LDFLAGS -lz -lm"
popd
mv bin/* $PREFIX/bin/
