#!/bin/bash

export BOOST_ROOT="${PREFIX}"

libs=
if [[ ${target_platform} =~ linux.* ]] ; then
    libs=-lrt
fi

autoreconf -fi
./configure \
  --prefix=${PREFIX} \
  --disable-perl \
  LIBS="${libs}"

make -j V=1
make check
make install
