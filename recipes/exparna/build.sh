#!/bin/bash

# create configure file
bash ./autotools-init.sh

# run configuration
./configure --prefix=$PREFIX --with-RNA=$PREFIX

# compile and install
make clean
make
make install
