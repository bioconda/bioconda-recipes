#!/bin/bash
set -eu -o pipefail

#if [[ "$(uname)" == Darwin ]]; then
#export CC=clang
#export CXX=clang++
#export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/c++/v1"
#export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
#fi

#lint failing 1
#lint failing 2
#linter failing 3
#linter failing 4
#linter failing 5
#linter failing 6
#linter failing 7
#linter failing 8
#linter failing 9
#linter failing 10
#linter failing 11
#linter failing 12
#linter failing 13
#linter failing 14
#linter failing 15
#linter failing 16
#linter failing 17
#linter failing 18
#linter failing 19
#linter failing 20
#linter failing 21 (still broken)
#linter failing 22
#linter failing 23 (good morning)
#linter failing 24 (good afternoon)
#linter failing 25 (PM checkin)
#linter failing 26 (lovely evening)
#linter failing 27 (sighh)
#linter failing 28 (good night)
#linter failing 29 (Morning check)
#linter failing 30 (the big 3-0 ... if this counter eclipses my age, I'll be sad :()
#linter failing 31 (and another one bites the dust?)
#linter failing 32 (powers of 2 are fun!)
#linter failing? 33 (lucky 33?)

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCONDA_BUILD=TRUE -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON ..
make
echo "unit test executable"
./src/unitTests
echo "installing"
make install CFLAGS="-L${PREFIX}/lib -I${PREFIX}/include"
../tests/unitTests
echo "cmake-powered unit test"
CTEST_OUTPUT_ON_FAILURE=1 make test

