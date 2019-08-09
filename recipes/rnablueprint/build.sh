#!/bin/bash

export BOOST_ROOT="${PREFIX}"

./configure \
  --prefix=${PREFIX} \
  --disable-perl \
  --disable-doxygen-doc

make -j
make check
make install
