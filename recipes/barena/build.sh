#!/bin/bash

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -m)" == "arm64" ]]; then
	nim_build="macosx_arm64"
	curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/${nim_build}.tar.xz -o ${nim_build}.tar.xz
	unxz -c ${nim_build}.tar.xz | tar -x
	cd nim-2.2.*
	export PATH="${PWD}/bin:${PATH}"
	cd ..
fi

if [[ "$(uname -m)" == "aarch64" ]]; then
	sed -i.bak 's|--passC:"-mpopcnt"||' nim.cfg
	rm -rf *.bak
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|--passC:"-mpopcnt"|--passC:"-Wno-incompatible-function-pointer-types"|' nim.cfg
fi

nimble --localdeps build -y --verbose -d:release

install -v -m 0755 somalier "${PREFIX}/bin"
