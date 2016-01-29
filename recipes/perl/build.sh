#!/bin/bash

# Build perl
sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc -Dcc=${PREFIX}/bin/gcc
make
make install
