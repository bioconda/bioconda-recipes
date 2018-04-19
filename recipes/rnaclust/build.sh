#!/bin/sh

find . -name \*.pl -exec sed  -i 's^/usr/bin/perl^/usr/bin/env perl^' {} \;
./configure --prefix=$CONDA_PREFIX && make && make install
