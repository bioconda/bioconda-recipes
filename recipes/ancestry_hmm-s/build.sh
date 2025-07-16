#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers

cd src

if [[ $(uname) == Darwin ]]; then
	sed -i.bak 's/-std=c++11/-std=c++11 -stdlib=libc++/' Makefile
fi


sed -i.bak 's#ahmms.cpp#ahmms.cpp -L ${PREFIX}/lib/ -I ${PREFIX}/include/#' Makefile 
sed -i.bak 's/ $(TCFLAGS)//' Makefile

make CXX=$CXX

mkdir -p $PREFIX/bin
cp ahmm-s $PREFIX/bin 
