#!/bin/bash

set -e -o pipefail

export CPATH="${PREFIX}/include"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,$PREFIX/lib -Wl,--no-as-needed"

make PREFIX="${PREFIX}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"
