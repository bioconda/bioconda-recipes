#!/bin/sh
# ViennaRNA does not support Python 3 yet.

if [ `uname` == Darwin ] ; then
    extra_config_options="--disable-openmp --enable-universal-binary"
fi

./configure --prefix=$PREFIX \
            --without-python --without-perl --without-ruby \
            ${extra_config_options} && \
make -j${CPU_COUNT} && \
make install
