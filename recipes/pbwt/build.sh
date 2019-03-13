#!/bin/bash
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export CXXFLAGS="${LDFLAGS} ${CPPFLAGS}"

git clone https://github.com/richarddurbin/pbwt
cd pbwt
git checkout 64c4ffa7880db5f85b53ccbd7e530ec4b95ea4ba
sed -i.bak 's/$(HTSLIB)/-lhts/' Makefile
make
cp pbwt $PREFIX/bin

