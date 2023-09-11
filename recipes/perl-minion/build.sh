#!/bin/bash

set -o errexit -o pipefail


perl Makefile.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
make
make test
make install
