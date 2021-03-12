#!/bin/bash

export BOOST_ROOT="${PREFIX}"

libs=
if [[ ${target_platform} =~ linux.* ]] ; then
    libs=-lrt
fi

autoreconf -fi
./configure \
  --prefix=${PREFIX} \
  LIBS="${libs}"

make -j
make check
make install
