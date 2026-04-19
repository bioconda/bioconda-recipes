#!/bin/bash
set -xe

export GOPATH="$PWD"
export GOCACHE="$PWD/.cache"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CGO_LDFLAGS="-L${PREFIX}/lib -lz"
export CGO_CFLAGS="$CGO_CFLAGS -I${PREFIX}/include"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

sed -i.bak 's|GOFLAGS=|GOFLAGS=-buildvcs=false -trimpath|' Makefile
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|1.26.1|1.24.13|' go.mod
	sed -i.bak 's|1.26.1|1.24.13|' go.work
	rm -f *.bak
    make CGO_CFLAGS="$CGO_CFLAGS -L$PREFIX/lib"
else
    make CGO_CFLAGS="$CGO_CFLAGS -L$PREFIX/lib"
fi

"${STRIP}" build/obi*

install -v -m 0755 build/obi* "${PREFIX}/bin"
