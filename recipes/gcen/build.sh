#!/bin/bash
set -x

mkdir -p "$PREFIX/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak 's|-std=c++11 -O3 -Wall|-std=c++14 -O3 -Wall -stdlib=libc++|' Makefile
else
  sed -i.bak 's|-std=c++11 -O3 -Wall|-std=c++14 -O3 -Wall|' Makefile
fi
rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 bin/* "$PREFIX/bin"
mv util/* "$PREFIX/bin"
