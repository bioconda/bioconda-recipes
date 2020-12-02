#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make \
  CXX="${CXX}" \
  all
cp libgab.a $PREFIX/lib/
cd ..

