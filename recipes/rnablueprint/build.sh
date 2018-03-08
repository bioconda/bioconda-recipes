#!/bin/bash

export BOOST_ROOT="${CONDA_PREFIX}"

#libtoolize --copy --force
#sh autogen.sh

./configure \
  --prefix=$PREFIX \
  --disable-perl \
  --disable-doxygen-doc \
  --disable-program \
  --disable-tests 

make -j
make install
