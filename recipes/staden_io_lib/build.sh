#!/bin/bash

./configure --prefix="${PREFIX}" --with-libdeflate="${PREFIX}" --with-libcurl="${PREFIX}" \
	--with-zlib="${PREFIX}" --with-zstd="${PREFIX}" "${EXTRA_ARGS}" --enable-shared --disable-static \
 	--disable-warnings --disable-dependency-tracking --disable-option-checkin --enable-silent-rules \
	CFLAGS="${CFLAGS} -O3"
make -j"${CPU_COUNT}"
make install
