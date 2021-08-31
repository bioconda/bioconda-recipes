#!/bin/bash
export BOOST_ROOT=${PREFIX}
export CFLAGS="$CFLAGS $LDFLAGS"
./configure --prefix=${PREFIX} --with-boost-libdir=${PREFIX}/lib
make
ls -lh
ls -lh src
mkdir -p ${PREFIX}/bin
mv src/Assemble ${PREFIX}/bin/
mv src/refine ${PREFIX}/bin/
mv src/connect_graph ${PREFIX}/bin/
mv src/TransLiG_iteration ${PREFIX}/bin/
mv src/Get_output ${PREFIX}/bin/
