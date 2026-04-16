#!/bin bash

set -xe
mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    export CGO_CFLAGS="${CGO_CFLAGS} -I${CONDA_PREFIX}/include"
else
    export CGO_CFLAGS="${CGO_CFLAGS} -L${CONDA_PREFIX}/lib -I${CONDA_PREFIX}/include"
fi

make GOFLAGS="-buildvcs=false"

for f in build/obi*; do
    [ -f "$f" ] && cp "$f" $PREFIX/bin/
done
