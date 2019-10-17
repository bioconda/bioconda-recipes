#!/usr/bin/env bash

cd projects/cmake

if [ ! -d build ]; then
	mkdir build
fi

./generate_version_number.sh
mv GitVersion.cpp ../../src/revlanguage/utils/
./regenerate.sh -boost false -mpi true

cd build

# INTERNAL_BOOST=OFF instructs not to use the included version
# If cmake finds a boost version compiled with cmake, it always links to it unless both
# Boost_NO_SYSTEM_PATHS=ON and Boost_NO_BOOST_CMAKE=ON (probably a bug in cmake)
cmake -DCMAKE_PREFIX_PATH=$PREFIX \
	-DBOOST_ROOT=$PREFIX \
	-DINTERNAL_BOOST=OFF \
	-DBoost_NO_SYSTEM_PATHS=ON \
	-DBoost_NO_BOOST_CMAKE=ON \
	.

make

cd ..
mkdir -p $PREFIX/bin
mv rb $PREFIX/bin


