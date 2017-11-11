#!/bin/bash

mkdir -p $PREFIX/bin
sed -i.bak "1 s|/usr/bin/make|$PREFIX/bin/make|"  bin/abyss-pe
rm bin/abyss-pe.bak

if [[ $(uname) == "Darwin" ]]; then
	echo "Configuring for OSX..."
	export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include -I$PREFIX/include/boost --stdlib=libstdc++"
	export CXXFLAGS="${CXXFLAGS} --stdlib=libstdc++"
	else
	echo "Configuring for Linux..."
	export CPPFLAGS="-I$PREFIX/include"
fi

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --with-mpi=$PREFIX/include --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

