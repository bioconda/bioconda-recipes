#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi

cd src

sed -i.bak 's#ahmms.cpp#ahmms.cpp -L ${PREFIX}/lib/ -I ${PREFIX}/include/#' Makefile 

make CXX=$CXX CXXFLAGS=$CXXFLAGS

mkdir -p $PREFIX/bin
cp ahmm-s $PREFIX/bin 
