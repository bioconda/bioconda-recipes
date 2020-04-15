#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

mkdir build && cd build && \
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBUILD_SHARED_LIB=ON ..
make && make install

cd ${SRC_DIR}/python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
