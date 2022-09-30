#!/bin/sh
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LIBRARY_PATH="${PREFIX}/lib:$LIBRARY_PATH"

export OBABEL="${LDFLAGS}"

sed -i.bak "s/CXXFLAGS=/CXXFLAGS+=/" Makefile
sed -i.bak "s|-c EDeN.cc|$CPPFLAGS -c EDeN.cc|" Makefile
sed -i.bak "s/CXX=g++\|-static//g" Makefile
cat Makefile
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
