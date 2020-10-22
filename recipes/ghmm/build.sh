#!/bin/bash

./autogen.sh
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
./configure --without-python --prefix=$PREFIX
make 
make install

cd ghmmwrapper
python setup.py build
python setup.py install
