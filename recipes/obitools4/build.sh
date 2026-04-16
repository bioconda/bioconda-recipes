#!/bin bash

set -xe
mkdir -p $PREFIX/bin

export GOFLAGS="-buildvcs=false"

if [ "$(uname)" == "Darwin" ]; then
    export CGO_CFLAGS="${CGO_CFLAGS} -I${CONDA_PREFIX}/include"
else
    export CGO_CFLAGS="${CGO_CFLAGS} -L${CONDA_PREFIX}/lib -I${CONDA_PREFIX}/include"
fi

make -e LDFLAGS=""

cp \
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
    ${PREFIX}/bin/
