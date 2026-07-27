#! /usr/bin/env bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/
export CGO_LDFLAGS = -L${GOPATH}/arachne/gobwa/bwa -L${GOPATH}/arachne/jemalloc/lib

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

# build jemalloc
cd arachne/jemalloc
./autogen.sh && ./configure --disable-shared --enable-static
cd ..
make -j 4 -C jemalloc build_lib_static

# build bwa
make -j 4 -C gobwa/bwa libbwa.a bwa

# build arachne
go build -ldflags "-X arachne/aligner.VERSION=$($PKG_VERSION)" -o $PREFIX/bin/arachne
chmod +x $PREFIX/bin/arachne
cp gobwa/bwa/bwa $PREFIX/bin/
