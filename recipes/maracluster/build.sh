#!/bin/bash

find / -name "*wiz*"

mkdir -p build/maracluster
cd build/maracluster

cmake -DTARGET_ARCH=amd64 -DCMAKE_BUILD_TYPE=Release  -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DBoost_NO_BOOST_CMAKE=ON -DVENDOR_SUPPORT=OFF -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_PREFIX_PATH="${SRC_DIR}/build/tools" "${SRC_DIR}";
make -j 4;
make -j 4 package;
make install
