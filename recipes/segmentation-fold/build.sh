#!/bin/sh

cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PREFIX .
cd test
make

make install
