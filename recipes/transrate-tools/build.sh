#!/bin/bash
set -ef -o pipefail

rm -rf bamtools
mkdir -p bamtools/include
ln -s $BUILD_PREFIX/lib bamtools/
ln -s $BUILD_PREFIX/include/bamtools/api bamtools/include/
ln -s $BUILD_PREFIX/include/bamtools/shared bamtools/include/

if [[ ${target_platform}  == "linux-aarch64" ]]; then
	sed -i "43c \\\  find_package (ZLIB REQUIRED)" CMakeLists.txt
fi
mkdir -p build
pushd build

mkdir -p $PREFIX/bin
export INCLUDE="$CONDA_PATH/include"
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_STATIC_LIBRARY_PREFIX=$PREFIX -DCMAKE_CXX_COMPILER=${CXX} ${SRC_DIR} -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DZLIBINCLUDE_DIR=$CONDA_PATH/include
make
cp src/bam-read $PREFIX/bin/
popd
