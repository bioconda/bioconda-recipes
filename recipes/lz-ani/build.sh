#!/bin/bash

if [ "$uname_S" == "Darwin" ]; then 
	brew install gcc-11
	brew install g++-11 
	CC=gcc-11
	CXX=g++-11
fi

ln -s ${CC} gcc
ln -s ${CXX} g++
export PATH=$PATH:$(pwd)
make -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install lz-ani "${PREFIX}/bin"
