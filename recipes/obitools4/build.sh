#!/bin bash
set -xe

export GOPATH="$PWD"
export GOCACHE="$PWD/.cache"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CGO_LDFLAGS="-L${PREFIX}/lib -lz"
export CGO_CFLAGS="$CGO_CFLAGS -I${PREFIX}/include"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

sed -i.bak 's|GOFLAGS=|GOFLAGS=-buildvcs=false|' Makefile
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET="12.0"
    export CGO_LDFLAGS="-mmacosx-version-min=12.0"
    make CGO_CFLAGS="$CGO_CFLAGS" LDFLAGS="${LDFLAGS}"
else
    make CGO_CFLAGS="$CGO_CFLAGS -L$PREFIX/lib" LDFLAGS="${LDFLAGS}"
fi

install -v -m 0755 build/obi* "${PREFIX}/bin"
