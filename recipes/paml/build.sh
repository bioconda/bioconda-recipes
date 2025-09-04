#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]]; then
	wget "https://github.com/abacus-gene/paml/releases/download/v${PKG_VERSION}/paml-${PKG_VERSION}-mac-arm64.tar.gz"
	tar -xvzf paml-${PKG_VERSION}-mac-arm64.tar.gz
	cd paml-${PKG_VERSION}-mac-arm64/bin
else
	cd src
	make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
	"${CC}" -o ds -O3 ds.c tools.c -lm
fi

install -v -m 0755 baseml basemlg \
	chi2 codeml ds evolver infinitesites \
	mcmctree pamp yn00 \
	"${PREFIX}/bin"

cp -rf "${SRC_DIR}/dat" ${PREFIX}/
