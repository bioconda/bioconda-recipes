#!/bin/bash

# Build perl
sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc
make
make install
