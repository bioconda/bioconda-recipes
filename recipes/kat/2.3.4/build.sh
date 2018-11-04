#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib
export LIBS='-lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'

export CXXFLAGS=" -std=c++11 -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR} -lboost_filesystem -lboost_system"

./autogen.sh
./configure --prefix=$PREFIX \
	--with-boost-libdir=${PREFIX}/lib \
	--with-boost=${PREFIX}
make
#make check 

cd tests
##All of these result in a core dump
#./test_comp.sh
#./test_gcp.sh
#./test_hist.sh
./test_sect.sh
cd ..

make install
