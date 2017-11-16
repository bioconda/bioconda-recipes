#!/bin/bash

if [[ $(uname) == "Darwin" ]]; then
	echo "Configuring for OSX..."
	export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include -I$PREFIX/include/boost --stdlib=libstdc++"
	export CXXFLAGS="${CXXFLAGS} --stdlib=libstdc++"
else
	echo "Configuring for Linux..."
	export CPPFLAGS="-I$PREFIX/include"
fi

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --with-mpi=$PREFIX/include --enable-maxk=128
make AM_CXXFLAGS=-Wall
make install 

$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-pe" "$PREFIX/bin/abyss-pe.Makefile"
$RECIPE_DIR/create-wrapper.sh "$PREFIX/bin/abyss-bloom-dist.mk" "$PREFIX/bin/abyss-bloom-dist.mk.Makefile"
