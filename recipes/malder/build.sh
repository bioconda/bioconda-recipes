#!/usr/bin/env bash

cd MALDER

if [[ $(uname -s) == Darwin ]]; then
	make CXX=clang++ \
		 CXXFLAGS="-Wall -Wno-return-type -Wno-write-strings -I$PREFIX/include -Iadmixtools_src -Iadmixtools_src/nicksrc" \
		 CFLAGS="-c -O2 -Wimplicit -Wno-return-type -Wno-write-strings -I$PREFIX/include -I. -I./nicksrc" \
		 L="-L$PREFIX/lib -lfftw3 -llapack -lgsl -fopenmp"
else
	make CXXFLAGS="-Wall -Wno-return-type -Wno-write-strings -I$PREFIX/include -Iadmixtools_src -Iadmixtools_src/nicksrc" \
		 CFLAGS="-c -O2 -Wimplicit -Wno-return-type -Wno-write-strings -I$PREFIX/include -I. -I./nicksrc" \
		 L="-L$PREFIX/lib -lfftw3 -llapack -lgsl -fopenmp"
fi

mkdir -p $PREFIX/bin
cp malder $PREFIX/bin/
