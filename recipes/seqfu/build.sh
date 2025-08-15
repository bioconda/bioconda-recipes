#!/bin/bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"

echo " Setting environment variables"
# Fix zlib
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

echo "CXX: ${CXX:-'not set'}"
echo "CC: ${CC:-'not set'}"
echo "----------"

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

if [[ "$(uname -s)" == "Darwin" ]]; then
	echo "OSX: Patching Makefile"
 	sed -i.bak 's|gcc|$(CC)|' Makefile
	sed -i.bak 's|g++|$(CXX)|' Makefile
	rm -rf *.bak
else
	# Trying to fix build when gcc or g++ are required
	echo "LINUX: Patching Makefile"
	sed -i 's/gcc/$(CC) $(LDFLAGS)/g' Makefile
	sed -i 's/g++/$(CXX) $(LDFLAGS)/g' Makefile
	rm -rf *.bak
fi

echo "## Automatic build: make"
make CC=${CC} CXX="${CXX}"

./bin/seqfu version || true

echo "## Current dir: $(pwd)"
install -v -m 0755 bin/* "${PREFIX}/bin"
