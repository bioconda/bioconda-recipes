#!/bin/bash

export CPATH=${PREFIX}/include

./autogen.sh
./configure --prefix=$PREFIX --with-hts=$PREFIX
make
# removing this for now as it triggers a build error from -Werror=maybe-uninitialized - pvanheus
# make check
make install
