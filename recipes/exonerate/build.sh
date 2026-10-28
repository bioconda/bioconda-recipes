#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
mkdir -p ${PREFIX}/bin

mv configure.in configure.ac

if [[ "$(uname -s)" == "Darwin" ]]; then
    # Fix for install_name_tool error:
    #   error: install_name_tool: changing install names or rpaths can't be
    #   redone for: ... (for architecture x86_64) because
    #   larger updated load commands do not fit (the program must be relinked,
    #   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

autoreconf -if
./configure --prefix="${PREFIX}" --enable-pthreads \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	--enable-utilities CC="${CC}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	CFLAGS="${CFLAGS}"

make -j"${CPU_COUNT}"
make install
