#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++14 -O3"

if [[ "$(uname -s)" == Darwin ]]; then
	# Fix for install_name_tool error:
	#   error: install_name_tool: changing install names or rpaths can't be
	#   redone for: $PREFIX/bin/abyss-overlap (for architecture x86_64) because
	#   larger updated load commands do not fit (the program must be relinked,
	#   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

autoreconf -if
./configure --prefix="${PREFIX}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--with-boost="${PREFIX}" \
	--with-mpi="${PREFIX}" \
	--with-sparsehash="${PREFIX}" \
	--without-sqlite \
	--disable-dependency-tracking --enable-silent-rules --disable-option-checking || cat config.log

make AM_CXXFLAGS="-Wall" -j"${CPU_COUNT}"
make install

$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-pe" "$PREFIX/bin/abyss-pe.Makefile"
$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-bloom-dist.mk" "$PREFIX/bin/abyss-bloom-dist.mk.Makefile"
