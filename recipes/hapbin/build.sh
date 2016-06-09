#!/bin/bash
cd build 
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ../src
make -d
make install
