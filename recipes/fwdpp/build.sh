#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

autoreconf -if
./configure --prefix="${PREFIX}" --disable-option-checking --enable-silent-rules \
    --disable-dependency-tracking CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"

cd testsuite
# For time reasons, 
# skip compiling & 
# executing long-running
# tests:
TESTS="unit/fwdpp_unit_tests unit/sugar_unit_tests unit/extensions_unit_tests integration/extensions_integration_tests"

make ${TESTS} -j"${CPU_COUNT}"

for i in $TESTS
do
    ./$i
done

cd ..
make install
