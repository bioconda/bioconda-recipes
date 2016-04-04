#!/bin/bash
export DYLD_LIBRARY_PATH=$PREFIX/lib

make
make install
