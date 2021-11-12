#!/bin/bash

./configure --prefix="${PREFIX}" --with-boost="${PREFIX}"

make -j 2
make install
install src/plotting_funcs.R "${PREFIX}/bin/"
