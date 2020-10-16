#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
	sed -i.bak 's/-std=c++11/-std=c++11 -stdlib=libc++/' Makefile
fi

cd src

sed -i.bak 's#ahmms.cpp#ahmms.cpp -L ${PREFIX}/lib/ -I ${PREFIX}/include/#' Makefile 

make CXX=$CXX

mkdir -p $PREFIX/bin
cp ahmm-s $PREFIX/bin 
