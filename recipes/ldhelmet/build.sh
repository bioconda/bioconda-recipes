#!/bin/bash

export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

make
chmod +x ldhelmet
cp ldhelmet $PREFIX/bin
