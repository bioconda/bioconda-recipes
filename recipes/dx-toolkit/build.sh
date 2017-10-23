#!/bin/bash

set -e -o pipefail

export CPATH="${PREFIX}/include"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

make PREFIX=${PREFIX} CPPFLAGS='-I${PREFIX}/include' CFLAGS='-I${PREFIX}/include' LDFLAGS='-L${PREFIX}/lib'
