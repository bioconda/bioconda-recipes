#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-implicit-int"

mkdir -p "${PREFIX}/bin"

# use newer config.guess and config.sub that support linux-aarch64
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

if [[ "$(uname -m)" == "arm64" ]]; then
	wget https://sourceforge.net/projects/argtable/files/argtable/argtable-2.13/argtable2-13.tar.gz/download -O argtable2-13.tar.gz
	tar -xvzf argtable2-13.tar.gz

	cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* argtable2-13/

	cd argtable2-13/
	autoreconf -if
	./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS}"
	make -j"${CPU_COUNT}"
	make install

	cd ..
fi

autoreconf -if

if [[ "$(uname -s)" == "Darwin" ]]; then
	# clang doesn't accept -fopenmp and there's no clear way around that
	./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS}"
else
	./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS} -DHAVE_OPENMP" OPENMP_CFLAGS='-fopenmp'
fi

make -j"${CPU_COUNT}"

install -v -m 0755 $SRC_DIR/src/clustalo "$PREFIX/bin"
