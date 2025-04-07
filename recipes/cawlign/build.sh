#!/usr/bin/env bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DUSE_OPENMP=ON .
make
make install
