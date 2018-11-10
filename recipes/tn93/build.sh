#!/bin/bash

cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_PREFIX=$PREFIX
make
make install
