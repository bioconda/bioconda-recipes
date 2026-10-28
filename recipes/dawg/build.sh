#!/bin/bash

cd build

if [[ ${target_platform} =~ linux.* ]] ; then
    # Workaround for glibc<2.17 where clock_gettime is in librt. (clock_time being used indirectly via Boost.)
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_EXE_LINKER_FLAGS_INIT=-lrt ..
else
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..
fi
make
make install
