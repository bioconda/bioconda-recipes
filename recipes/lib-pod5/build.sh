#!/bin/bash
$PYTHON -m setuptools_scm
$PYTHON -m pod5_make_version

mkdir build
cd build
conan install --build=missing -s build_type=Release .. 
cmake -DENABLE_CONAN=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j
