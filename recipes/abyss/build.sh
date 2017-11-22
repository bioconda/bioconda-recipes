#!/bin/bash

./configure \
    --prefix="$PREFIX" \
    --with-boost="$PREFIX" \
    --with-mpi="$PREFIX" \
    --with-sparsehash="$PREFIX" \
    --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-pe" "$PREFIX/bin/abyss-pe.Makefile"
$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-bloom-dist.mk" "$PREFIX/bin/abyss-bloom-dist.mk.Makefile"
