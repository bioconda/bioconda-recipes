#!/bin/sh
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' tRNAscan-SE.src
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/instman.pl

./configure --prefix=$PREFIX

make
make install

# run a small test
$PREFIX/bin/tRNAscan-SE --quiet --breakdown --hitsrc --detail Demo/Example1.fa 2>/dev/null | diff Demo/Example1-tRNAs.out -
