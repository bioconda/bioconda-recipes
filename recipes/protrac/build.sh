#!/bin/bash
mkdir -p $PREFIX/bin
chmod +x proTRAC_$PKG_VERSION.pl

perl -i -wpe 's/\r/\n/g' proTRAC_$PKG_VERSION.pl
perl -i -wpe 's/\/perl/\/env perl/' proTRAC_$PKG_VERSION.pl

cp proTRAC_$PKG_VERSION.pl $PREFIX/bin
