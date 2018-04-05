#!/bin/bash
cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX .
make 
make test
make install
