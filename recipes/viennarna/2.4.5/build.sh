#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    extra_config_options="--disable-openmp 
                          --without-python3
                          LDFLAGS=-Wl,-headerpad_max_install_names"
fi

## Configure and make
./configure --prefix=$PREFIX \
            --without-perl \
            --with-kinwalker \
            --with-cluster \
            --disable-lto \
            --without-doc \
            --without-tutorial \
            --without-tutorial-pdf \
            ${extra_config_options}

make -j${CPU_COUNT}

## Install
make install
