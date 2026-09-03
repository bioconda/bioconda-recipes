#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -D_LIBCPP_DISABLE_AVAILABILITY"
export LC_ALL="en_US.UTF-8"

sed -i.bak -e 's/install -d/mkdir -p/' Makefile
rm -f *.bak

make -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"

ln -s ${PREFIX}/bin/adapterremoval3 ${PREFIX}/bin/adapterremoval
