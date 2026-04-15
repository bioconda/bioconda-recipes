#!/bin bash
set -xe

export CGO_ENABLED=0
export GOPATH="$PWD"
export GOCACHE="$PWD/.cache"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

sed -i.bak 's|GOFLAGS=|GOFLAGS=-buildvcs=false|' Makefile
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET="12.0"
    GOFLAGS="-buildvcs=false" make "CGO_CFLAGS=$CGO_CFLAGS -I${PREFIX}/include"
else
    GOFLAGS="-buildvcs=false" make "CGO_CFLAGS=$CGO_CFLAGS -L$PREFIX/lib -I$PREFIX/include"
fi

install -v -m 0755 \
    build/obiannotate \
    build/obiclean \
    build/obicleandb \
    build/obicomplement \
    build/obiconsensus \
    build/obiconvert \
    build/obicount \
    build/obicsv \
    build/obidemerge \
    build/obidistribute \
    build/obigrep \
    build/obijoin \
    build/obikmermatch \
    build/obikmersimcount \
    build/obilandmark \
    build/obimatrix \
    build/obimicrosat \
    build/obimultiplex \
    build/obipairing \
    build/obipcr \
    build/obireffamidx \
    build/obirefidx \
    build/obiscript \
    build/obisplit \
    build/obisummary \
    build/obitag \
    build/obitagpcr \
    build/obitaxonomy \
    build/obiuniq \
    "${PREFIX}/bin"
