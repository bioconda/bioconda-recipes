#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

meson setup build --prefix ${PREFIX}
cd build
ninja
ninja install
