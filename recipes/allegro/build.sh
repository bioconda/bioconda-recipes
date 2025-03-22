#!/bin/bash
rm -rf src/config.guess
rm -rf src/config.sub
wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -O src/config.guess
wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -O src/config.sub
./configure
make CXXFLAGS="${CXXFLAGS} -std=c++03"

cp allegro $PREFIX/bin
