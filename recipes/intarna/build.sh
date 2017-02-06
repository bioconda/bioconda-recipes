#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    extra_config_options=""
else ## linux
    # add -fopenmp to compilation due to viennarna setup
    extra_config_options="CXX_FLAGS=-fopenmp"
fi

./configure --prefix=$PREFIX \
            --with-RNA=$PREFIX \
            --with-boost=$PREFIX \
            --disable-multithreading \
            ${extra_config_options} \
            && \
make && \
make install
