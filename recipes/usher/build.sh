#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p build
pushd build

cmake -DTBB_DIR=${PWD}/../oneTBB-2019_U9 -DCMAKE_PREFIX_PATH=${PWD}/../oneTBB-2019_U9/cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..

make -j 1

cp ./usher ${PREFIX}/bin/
cp ./matUtils ${PREFIX}/bin/
cp ./matOptimize ${PREFIX}/bin/
cp ./tbb_cmake_build/tbb_cmake_build_subdir_release/* ${PREFIX}/lib/

popd
