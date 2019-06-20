#!/bin/bash
cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX .
make install
