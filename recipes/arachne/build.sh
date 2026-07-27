#! /usr/bin/env bash

export GOPATH=$PWD
export GOCACHE=$PWD/.cache/
export CGO_LDFLAGS="-L${GOPATH}/gobwa/bwa -L${GOPATH}/jemalloc/lib"
export CFLAGS="${CFLAGS} -g -Wall -Wno-unused-function -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

# build jemalloc
cd jemalloc
./autogen.sh && ./configure --disable-shared --enable-static
cd ..
make -j 4 CC="${CC}" -C jemalloc build_lib_static


# build bwa
make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}" -C gobwa/bwa libbwa.a bwa
#make -j 4 CC="${CC}" -C gobwa/bwa libbwa.a bwa

# build arachne
go build -ldflags "-X arachne/aligner.VERSION=${$PKG_VERSION}" -o $PREFIX/bin/arachne
chmod +x $PREFIX/bin/arachne
install -v -m 0755 gobwa/bwa/bwa "${PREFIX}/bin"
