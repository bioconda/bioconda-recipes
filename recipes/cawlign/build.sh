#!/usr/bin/env bash

# Clear CMake cache and force our prefix
rm -rf CMakeCache.txt CMakeFiles/
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_PREFIX=$PREFIX -DCMAKE_POLICY_VERSION_MINIMUM=3.10 .
make
make install
