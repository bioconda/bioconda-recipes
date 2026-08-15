#!/bin/bash

cd gvcf2coverage

make CC="${CC}" HTSLIB_INCDIR="$PREFIX/include" HTSLIB_LIBDIR="$PREFIX/lib" -j"${CPU_COUNT}"
make install
