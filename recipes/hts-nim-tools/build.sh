#!/bin/bash
set -eu -o pipefail

export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -m)" == "arm64" ]]; then
	nim_build="macosx_arm64"
	curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/${nim_build}.tar.xz -o ${nim_build}.tar.xz
	unxz -c ${nim_build}.tar.xz | tar -x

	cd nim-2.2.*
	export PATH="${PWD}/bin:${PATH}"
	cd ..

	echo "gcc.exe = \"${CC}\"" >> nim-2.2.*/config/nim.cfg
	echo "gcc.linkerexe =\"${CC}\"" >>  nim-2.2.*/config/nim.cfg
	echo "gcc.options.linker %= \"\${gcc.options.linker} ${LDFLAGS}\"" >>  nim-2.2.*/config/nim.cfg
	cat nim-2.2.*/config/nim.cfg
fi

pushd hts-nim
nimble install -y
popd

nimble install -y

install -v -m 0755 hts_nim_tools "${PREFIX}/bin"
