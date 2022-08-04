#!/bin/bash

mkdir -p $PREFIX/bin

if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -sSLO https://github.com/oneapi-src/oneTBB/releases/download/2019_U9/tbb2019_20191006oss_mac.tgz
    tar -xzf tbb2019_20191006oss_mac.tgz
    tbb_root=tbb2019_20191006oss
else
    curl -sSLO https://github.com/oneapi-src/oneTBB/archive/2019_U9.tar.gz
    tar -xzf 2019_U9.tar.gz
    tbb_root=oneTBB-2019_U9
fi

mkdir -p build
pushd build

cmake -DTBB_DIR=${PWD}/../$tbb_root -DCMAKE_PREFIX_PATH=${PWD}/../$tbb_root/cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..

make -j 1

cp ./usher ${PREFIX}/bin/
cp ./matUtils ${PREFIX}/bin/
cp ./matOptimize ${PREFIX}/bin/
if [ -f "ripples" ]; then
    cp ./ripples ${PREFIX}/bin/
fi
if [ -d ./tbb_cmake_build ]; then
    cp ./tbb_cmake_build/tbb_cmake_build_subdir_release/* ${PREFIX}/lib/
elif [[ "$OSTYPE" == "darwin"* ]]; then
    cp ../$tbb_root/lib/* ${PREFIX}/lib/
fi

popd
