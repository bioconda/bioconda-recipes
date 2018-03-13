#!/bin/bash

export BOOST_ROOT="${CONDA_PREFIX}"

./configure \
  --prefix=${PREFIX} \
  --disable-perl \
  --disable-doxygen-doc \
  --disable-program

make -j
make check
make install
