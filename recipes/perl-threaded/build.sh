#!/bin/bash

# Build perl
if [ "$(uname)" == "Darwin" ]; then
    sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc -Dusethreads -Dcc=clang
else
    sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc -Dusethreads -Dcc=gcc
fi

make
make install
