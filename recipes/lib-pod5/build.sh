#!/bin/bash
set -ex

$PYTHON -m setuptools_scm
$PYTHON -m pod5_make_version

mkdir build
cd build
conan install --build=missing -s build_type=Release -s compiler=$CXX .. 
cmake -DENABLE_CONAN=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j
