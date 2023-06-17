#! /bin/bash
mkdir -p $PREFIX/bin

sed -i.bak 's/CXX *=/CXX ?=/; s/CXXFLAGS *=/CXXFLAGS +=/' Makefile

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="-I$PREFIX/include -L$PREFIX/lib"
make 

cp candidate_variants_finder $PREFIX/bin
cp emvc-2 $PREFIX/bin
