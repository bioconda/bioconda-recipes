#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
