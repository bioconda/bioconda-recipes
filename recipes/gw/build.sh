#!/usr/bin/bash
set -e
sed -i.bak "s/-dynamic//g" Makefile
make prep
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" make
mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
chmod +x $PREFIX/bin/gw
