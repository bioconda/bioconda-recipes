#!/bin/bash
wget https://github.com/simongog/sdsl-lite/releases/download/v2.1.1/sdsl-lite-2.1.1.tar.gz.offline.install.gz
tar xf sdsl-lite-2.1.1.tar.gz.offline.install.gz
sed -i 's/cmake_minimum_required(VERSION 2.8.11)/cmake_minimum_required(VERSION 3.5...3.20)/' sdsl-lite-2.1.1/CMakeLists.txt
sed -i 's|cmake_minimum_required(VERSION 2.4.4)|cmake_minimum_required(VERSION 3.5...3.20)|' ./sdsl-lite-2.1.1/external/libdivsufsort/CMakeLists.txt
sed -i 's|cmake_minimum_required(VERSION 2.6.4)|cmake_minimum_required(VERSION 3.5...3.20)|' ./sdsl-lite-2.1.1/external/googletest/CMakeLists.txt
sed -i 's|cmake_minimum_required(VERSION 2.6.4)|cmake_minimum_required(VERSION 3.5...3.20)|' ./sdsl-lite-2.1.1/external/googletest/googletest/CMakeLists.txt
sed -i 's|cmake_minimum_required(VERSION 2.6.4)|cmake_minimum_required(VERSION 3.5...3.20)|' ./sdsl-lite-2.1.1/external/googletest/googlemock/CMakeLists.txt
sed -i 's/tree\.m_select1/tree\.m_bv_select1/g;s/tree\.m_select0/tree\.m_bv_select0/g' ./sdsl-lite-2.1.1/include/sdsl/louds_tree.hpp
sed -i '6a#include <cstdint>' ./include/common_types.h
sed -i 's/-march=nocona//g' ./CMakeLists.txt
sed -i 's/-mtune=haswell//g' ./CMakeLists.txt
pushd sdsl-lite-2.1.1
mkdir $SRC_DIR/sdsl-build
CXXFLAGS="${CXXFLAGS} -std=gnu++1z"
./install.sh $SRC_DIR/sdsl-build
sed -i 's/cmake_minimum_required(VERSION 3.5 FATAL_ERROR)/cmake_minimum_required(VERSION 3.10...3.27)/g' CMakeLists.txt
rm -rf build
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DNH=1 -DSDSL_INSTALL_PATH=$SRC_DIR/sdsl-build -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make install VERBOSE=1
popd

