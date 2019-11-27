#!/bin/sh

# Overwrite plot-vcfstats with updated version
ls
cmake .
make
make install PREFIX=$PREFIX

#cmake -D CMAKE_AR=$(which x86_64-conda_cos6-linux-gnu-ar)\
#      .
# make
# bin_loc=$(readlink -f bin/scssim)
# popd
# popd
# install $bin_loc bin
# rm -rf $wd  


# sed -i.bak 's@^#!/usr/bin/perl -w@#!/opt/anaconda1anaconda2anaconda3/bin/perl@' misc/vcfutils.pl
# ./configure --prefix=$PREFIX --with-htslib=system --enable-libgsl
# make all
# make install
