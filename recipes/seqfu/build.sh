#!/bin/bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -m)" == "arm64" ]]; then
	nim_build="macosx_arm64"
	curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/${nim_build}.tar.xz -o ${nim_build}.tar.xz
	unxz -c ${nim_build}.tar.xz | tar -x
	cd nim-2.2.*
	export PATH="${PWD}/bin:${PATH}"
	cd ..
fi

echo "--- NIM BUILD ---"
nim --version
echo "----------"



echo " Setting environment variables"
# Fix zlib
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

echo "GXX: ${GXX:-'not set'}"
echo "GCC: ${GCC:-'not set'}"
echo "----------"



if [[ "$(uname -s)" == "Darwin" ]]; then
	echo "OSX"
	export HOME="/Users/distiller"
	export HOME=`pwd`
else
	# Trying to fix build when gcc or g++ are required
	echo "LINUX: Patching makefile"
	sed -i 's/gcc/gcc $(LDFLAGS)/g' Makefile
	sed -i 's/g++/g++ $(LDFLAGS)/g' Makefile
	sed -i 's/gcc/$(GCC)/g' Makefile
	sed -i 's/g++/$(GXX)/g' Makefile
	sed -i '1iGCC ?= gcc' Makefile
	sed -i '1iGXX ?= g++' Makefile
fi


echo "## Automatic build: install deps"
nimble install -y --depsOnly
echo "## Automatic build: make"
make

./bin/seqfu version || true

echo "## Current dir: $(pwd)"
install -v -m 0755 bin/* "$PREFIX/bin"

echo "## List files in \$PREFIX/bin:"
ls -ltr "$PREFIX/bin"
