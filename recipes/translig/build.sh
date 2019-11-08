#!/bin/bash
export BOOST_ROOT=${PREFIX}
export CFLAGS="$CFLAGS $LDFLAGS"
./configure --prefix=${PREFIX} --with-boost-libdir=${PREFIX}/lib
make
mkdir -p ${PREFIX}/bin
mv Assemble ${PREFIX}/bin/
mv refine ${PREFIX}/bin/
mv connect_graph ${PREFIX}/bin/
mv TransLiG_iteration ${PREFIX}/bin/
mv Get_output ${PREFIX}/bin/
