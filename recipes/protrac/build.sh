#!/bin/bash
export LC_ALL=C
export LANG=C
mkdir -p $PREFIX/bin
chmod +x proTRAC_$PKG_VERSION.pl
sed -i -e 's/\r/\n/g' proTRAC_$PKG_VERSION.pl
sed -i -e 's/\/perl/\/env perl/' proTRAC_$PKG_VERSION.pl
cp proTRAC_$PKG_VERSION.pl $PREFIX/bin
