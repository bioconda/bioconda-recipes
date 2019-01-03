#!/bin/bash

cd htslib
autoreconf -fi
./configure --prefix=`pwd`
make install

cd ../ivar/

./autogen.sh
./configure --prefix=$PREFIX --with-hts=$(pwd ../)/htslib
make
make install
