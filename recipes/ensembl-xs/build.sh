#!/usr/bin/env bash
set -o pipefail

export C_INCLUDE_PATH=${PREFIX}/include

perl Makefile.PL PREFIX=${PREFIX} INSTALLDIRS=site
make
make test 2>&1
make install