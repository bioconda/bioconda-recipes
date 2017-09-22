#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

find / -name "zlib.h"

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
