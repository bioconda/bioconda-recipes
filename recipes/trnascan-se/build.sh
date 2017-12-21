#!/bin/sh
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' tRNAscan-SE.src
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/instman.pl

./configure --prefix=$PREFIX

make
make install
