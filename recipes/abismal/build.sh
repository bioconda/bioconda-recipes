#!/bin/bash
./configure --prefix=$PREFIX
make CXXFLAGS="-O3 -D_LIBCPP_DISABLE_AVAILABILITY"
make install
