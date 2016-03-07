#!/bin/bash

# Build perl
sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc -Dusethreads -Dcc=${PREFIX}/bin/gcc
make
make install
