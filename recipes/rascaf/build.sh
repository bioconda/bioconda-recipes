#!/bin/bash
mkdir -p ${PREFIX}/bin
export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
make
mv *.pl ${PREFIX}/bin/
chmod a+x ${PREFIX}/bin/*.pl
mv rascaf ${PREFIX}/bin/
mv rascaf-join ${PREFIX}/bin/
