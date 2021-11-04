#!/bin/bash
export BOOST_ROOT=${PREFIX}
export CFLAGS="$CFLAGS $LDFLAGS"
# dpkg -s libboost-dev | grep 'Version'
export boost_cv_lib_version=1_74_0
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
mv src/TransLIG ${PREFIX}/bin/
