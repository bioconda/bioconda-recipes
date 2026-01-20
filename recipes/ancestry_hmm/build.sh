#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers

cd src

if [[ $(uname) == Darwin ]]; then
	sed -i.bak 's/-O3/-stdlib=libc++ -O3/' Makefile
fi


sed -i.bak 's#ahmms.cpp#ahmms.cpp -L ${PREFIX}/lib/ -I ${PREFIX}/include/#' Makefile 
sed -i.bak 's#ancestry_hmm.cpp#ancestry_hmm.cpp -L ${PREFIX}/lib/ -I ${PREFIX}/include/#' Makefile 
#sed -i.bak 's/ $(TCFLAGS)//' Makefile

make CXX=$CXX

mkdir -p $PREFIX/bin
cp ahmm-s ancestry_hmm $PREFIX/bin 
