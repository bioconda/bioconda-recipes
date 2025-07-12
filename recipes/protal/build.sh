#!/bin/bash
echo $PWD
ls $PWD

# mkdir build
# cd build

rm -rf cmake-build-release
mkdir -p cmake-build-release

echo "Step 1"
echo $PWD
echo "...SRCDIR= $SRC_DIR"
export VERBOSE=1

cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_MAKE_PROGRAM=make \
	-DCMAKE_C_COMPILER=$GCC \
	-DCMAKE_CXX_COMPILER=$GXX \
	-G "CodeBlocks - Unix Makefiles" \
	-S $SRC_DIR \
	-B cmake-build-release \
    -DCMAKE_VERBOSE_MAKEFILE=ON


	# -S ./../ \

echo "Step 2"
echo $PWD
echo "cmake --build cmake-build-release --target protal -- -j 6"

cmake --build cmake-build-release --target protal -- -j 6
cmake --build cmake-build-release --target protal_avx2 -- -j 6

cp cmake-build-release/protal ${PREFIX}/bin/protal_plain
cp cmake-build-release/protal_avx2 ${PREFIX}/bin/protal_avx2
cp protal_launcher ${PREFIX}/bin/protal
