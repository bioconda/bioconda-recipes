#!/bin/bash

mkdir -p $PREFIX/bin

cd rainbow_$PKG_VERSION

make

cp rainbow $PREFIX/bin

cp select_all_rbcontig.pl $PREFIX/bin
cp select_best_rbcontig.pl $PREFIX/bin
cp select_sec_rbcontig.pl $PREFIX/bin
cp select_best_rbcontig_plus_read1.pl $PREFIX/bin

chmod +x $PREFIX/bin/select_*

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/select_*.pl
