#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

if [[ "$(uname -m)" == "arm64" ]]; then
	nim_build="macosx_arm64"
	curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/${nim_build}.tar.xz -o ${nim_build}.tar.xz
	unxz -c ${nim_build}.tar.xz | tar -x

	cd nim-2.2.*
	export PATH="${PWD}/bin:${PATH}"
	cd ..
fi

pushd hts-nim
nimble install -y --verbose
popd

pushd genoiser
nimble install -y --verbose
popd

nimble install -y --verbose -d:release

install -v -m 0755 duphold "${PREFIX}/bin"
