#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    extra_config_options="LDFLAGS=-Wl,-headerpad_max_install_names"
fi

if [ $PY3K -eq 1 ]; then
    VRNA_PYFLAGS="--without-python2"
else
    VRNA_PYFLAGS="--without-python"
fi

## Configure and make
./configure --prefix=$PREFIX \
            ${VRNA_PYFLAGS} \
            --with-kinwalker \
            --with-cluster \
            --disable-lto \
            --without-doc \
            --without-tutorial \
            --without-tutorial-pdf \
            --without-cla \
            ${extra_config_options} \
            && \
make -j${CPU_COUNT}

## Install
make install
