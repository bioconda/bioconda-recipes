#!/bin/bash
export BOOST_ROOT=${PREFIX}
export CFLAGS="$CFLAGS $LDFLAGS"
export boost_cv_lib_version=`dpkg -s libboost-dev | grep ' Boost version' | sed 's/[a-zA-Z]\|(\|)\| //g' | sed 's/\./_/g' | sed 's/_$/_0/'`
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
mv TransLiG ${PREFIX}/bin/
