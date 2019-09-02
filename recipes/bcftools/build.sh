#!/bin/sh

# Overwrite plot-vcfstats with updated version
curl https://raw.githubusercontent.com/samtools/bcftools/44c660490411cbc0611e405a8ebf3faa0d65c544/misc/plot-vcfstats -o misc/plot-vcfstats

export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export CFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak 's@^#!/usr/bin/perl -w@#!/opt/anaconda1anaconda2anaconda3/bin/perl@' misc/vcfutils.pl
./configure --prefix=$PREFIX --enable-libcurl --enable-libgsl CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make all
make install
