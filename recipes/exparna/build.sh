#!/bin/sh
# temp debug
cat autotools-init.sh
# create configure file
sh autotools-init.sh
# run configuration
./configure --prefix=$PREFIX --with-RNA=$PREFIX
# compile and install
make clean
make
make install
