#!/bin/bash
set -x

mkdir -p "${PREFIX}/bin"

export LIBRARY_PATH="$LIBRARY_PATH:$PREFIX/lib"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:$PREFIX/include"

sed -i.bak 's|-lpthread|-pthread|' nim.cfg
rm -rf *.bak

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

	nim c -y --verbose -d:d4 -d:release --mm:refc --passC:"-I$PREFIX/include" --passL:"-L$PREFIX/lib" ./mosdepth.nim
else
	nim c -y --verbose -d:d4 -d:release --mm:refc --passC:"-I$PREFIX/include" --passL:"-L$PREFIX/lib" ./mosdepth.nim
fi

install -v -m 755 mosdepth "${PREFIX}/bin"
