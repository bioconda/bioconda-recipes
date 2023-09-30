#!/bin/bash
make CC=$CC CXX="${CXX}" LDFLAGS="$LDFLAGS -L$PREFIX/lib" LIBPATH="-L${PREFIX}/lib" LIBRARY_PATH="${PREFIX}/lib"
mkdir -p $PREFIX/bin
cp viral_consensus $PREFIX/bin/
