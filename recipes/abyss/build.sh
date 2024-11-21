#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == Darwin ]]; then
    # Fix for install_name_tool error:
    #   error: install_name_tool: changing install names or rpaths can't be
    #   redone for: $PREFIX/bin/abyss-overlap (for architecture x86_64) because
    #   larger updated load commands do not fit (the program must be relinked,
    #   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

autoreconf -if
./configure --prefix="${PREFIX}" \
	CXXFLAGS="${CXXFLAGS} -std=c++14 -O3 -I${PREFIX}/include" \
	--with-boost="${PREFIX}" \
	--with-mpi="${PREFIX}" \
	--with-sparsehash="${PREFIX}" \
	--without-sqlite || cat config.log
make AM_CXXFLAGS="-Wall" -j"${CPU_COUNT}"
make install

$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-pe" "$PREFIX/bin/abyss-pe.Makefile"
$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-bloom-dist.mk" "$PREFIX/bin/abyss-bloom-dist.mk.Makefile"
