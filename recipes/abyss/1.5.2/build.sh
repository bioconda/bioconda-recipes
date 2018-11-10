#!/bin/bash

if [[ "$(uname)" == Darwin ]]; then
    # Fix for install_name_tool error:
    #   error: install_name_tool: changing install names or rpaths can't be
    #   redone for: $PREFIX/bin/abyss-overlap (for architecture x86_64) because
    #   larger updated load commands do not fit (the program must be relinked,
    #   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

SPARSE_HASH_INCLUDE="-I$PREFIX/include"
CPPFLAGS="$CPPFLAGS $SPARSE_HASH_INCLUDE"

BOOST_INCLUDE="$PREFIX/include"
./configure \
    --prefix="$PREFIX" \
    --with-boost="$BOOST_INCLUDE" \
    --with-mpi="$PREFIX" \
    --with-sparsehash="$PREFIX"
make AM_CXXFLAGS=-Wall
make install

$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-pe" "$PREFIX/bin/abyss-pe.Makefile"
$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-bloom-dist.mk" "$PREFIX/bin/abyss-bloom-dist.mk.Makefile"
