#!/bin/sh

export CXXFLAGS="${CXXFLAGS/-std=c++17/-std=gnu++17} -Wno-unused-result"

autoreconf -i \
&& \
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH" \
  ./configure --prefix="$PREFIX" CPPFLAGS="-I $PREFIX/include" && \
make ${CPUS_COUNT} && \
make install
