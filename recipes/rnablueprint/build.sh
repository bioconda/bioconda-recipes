#!/bin/bash

export BOOST_ROOT="${PREFIX}"

./configure \
  --prefix=${PREFIX} \
  --disable-perl \
  --disable-doxygen-doc

make -j V=1
make check V=1
make install
