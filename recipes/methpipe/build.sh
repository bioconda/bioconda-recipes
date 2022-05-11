#!/bin/bash

mkdir build && cd build
cmake ../ -DBOOST_ROOT=$PREFIX -DAGS_EXAMPLE_CPP_LIB_ROOT=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX
#../configure --prefix ${PREFIX}
make
make install
