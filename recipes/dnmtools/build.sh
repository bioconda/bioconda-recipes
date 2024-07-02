#!/bin/bash

./configure --prefix=$PREFIX
make CXXFLAGS="-O3 -DNDEBUG -D_LIBCPP_DISABLE_AVAILABILITY"
make install
