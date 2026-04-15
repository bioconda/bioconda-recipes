#!/bin bash
set -xe

export GOPATH="$PWD"
export GOCACHE="$PWD/.cache"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

sed -i.bak 's|GOFLAGS=|GOFLAGS=-buildvcs=false|' Makefile
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET="12.0"
    make CGO_CFLAGS="$CGO_CFLAGS -I${PREFIX}/include"
else
    make CGO_CFLAGS="$CGO_CFLAGS -L$PREFIX/lib -I$PREFIX/include"
fi

install -v -m 0755 "build/obi*" "${PREFIX}/bin"
