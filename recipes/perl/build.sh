#!/bin/bash

# Build perl
sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc -Dusethreads
make
make install
