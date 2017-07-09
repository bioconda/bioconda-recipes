#!/bin/sh

./configure --prefix=$PREFIX --with-vrna=$PREFIX "${extra_config_options}" && \
make -j ${CPU_COUNT} && \
make install
