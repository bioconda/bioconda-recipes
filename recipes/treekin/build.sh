#!/bin/sh

export CXXFLAGS="${CXXFLAGS/-std=c++17/-std=gnu++17} -Wno-unused-result"

autoreconf -i \
&& \
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH" \
  ./configure --prefix="$PREFIX" && \
make ${CPUS_COUNT} V=2 && \
make install
