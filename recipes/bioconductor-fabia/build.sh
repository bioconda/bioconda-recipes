#!/bin/bash

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

if [[ "$(uname)" == "Darwin" ]]; then
    export CC=clang
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi
autoconf

$R CMD INSTALL --build . || (echo "error code: $?" ; cat config.log ; exit 1)
