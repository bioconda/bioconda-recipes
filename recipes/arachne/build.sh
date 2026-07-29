#! /usr/bin/env bash

export GOCACHE="$PWD/.cache"
export CGO_ENABLED=1
export GO111MODULE=on
export CGO_LDFLAGS="-L${SRC_DIR}/gobwa/bwa -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -g -Wall -Wno-unused-function -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export MACOSX_DEPLOYMENT_TARGET=11.0

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

# build bwa
make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}" -C gobwa/bwa libbwa.a bwa

# build arachne
go version
go env
echo "MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET"

go build -ldflags "-X arachne/aligner.VERSION=${PKG_VERSION}" -o $PREFIX/bin/arachne
chmod +x $PREFIX/bin/arachne
install -v -m 0755 gobwa/bwa/bwa "${PREFIX}/bin"
