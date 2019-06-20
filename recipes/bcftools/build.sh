#!/bin/sh

# Overwrite plot-vcfstats with updated version
curl https://raw.githubusercontent.com/samtools/bcftools/44c660490411cbc0611e405a8ebf3faa0d65c544/misc/plot-vcfstats -o misc/plot-vcfstats

export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export CFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make all
make install
