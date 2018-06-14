#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    extra_config_options="--disable-openmp 
                          --enable-universal-binary
                          LDFLAGS=-Wl,-headerpad_max_install_names"
fi

if [[ "${PY_VER}" =~ ^3 ]]
then
    extra_config_options="--with-python3 $extra_config_options"
else
    extra_config_options="--with-python $extra_config_options"
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
            ${extra_config_options} \
            &&\
make -j${CPU_COUNT}

## Install
make install
