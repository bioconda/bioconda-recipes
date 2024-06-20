#!/bin/bash

set -xe

wget https://download.build2.org/0.17.0/build2-install-0.17.0.sh

sh build2-install-0.17.0.sh --yes --trust yes --timeout 6000 --jobs ${CPU_COUNT} ${PREFIX}


mkdir xsd-build
$ cd xsd-build

$ bpkg create -d xsd-gcc-N cc     \
  config.cxx=${CXX}               \
  config.cc.coptions=${CFLAGS}    \
  config.bin.rpath=${PREFIX}/lib  \
  config.install.root=${PREFIX}   \
  config.install.sudo=false

make CC="$CC" CXX="$CXX" AR="$AR" RANLIB="$RANLIB" CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS -std=c++14" LDFLAGS="$LDFLAGS" -j ${CPU_COUNT}
make install_prefix="$PREFIX" install





bpkg create -d xsd-gcc-N cc     \
  config.cxx=g++                  \
  config.cc.coptions=-O3          \
  config.bin.rpath=/usr/local/lib \
  config.install.root=/tmp/usr/local  \
  config.install.sudo=sudo

cd xsd-gcc-N

bpkg build --trust-yes --jobs 6 --progress xsd@https://pkg.cppget.org/1/beta