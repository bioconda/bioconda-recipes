#!/bin/bash
cmake -D CMAKE_INSTALL_PREFIX=${PREFIX} .
make
make test
make install
