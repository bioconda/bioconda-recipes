#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export CPATH="${PREFIX}/include"

autoreconf -if
./configure --prefix="$PREFIX" --with-hts="$PREFIX" CXX="${CXX}"
make -j"${CPU_COUNT}"
# removing this for now as it triggers a build error from -Werror=maybe-uninitialized - pvanheus
# make check
make install
