#!/bin/sh
# ViennaRNA does not support Python 3 yet.

if [ `uname` == Darwin ] ; then
    extra_config_options="--disable-openmp 
                          --enable-universal-binary 
                          LDFLAGS=-Wl,-headerpad_max_install_names"
fi

./configure --prefix=$PREFIX \
            --without-perl --without-python --with-python3 \
            ${extra_config_options} && \
make -j${CPU_COUNT} && \
make install
